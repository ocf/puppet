import importlib.machinery
import importlib.util
import pathlib
import subprocess
import unittest
from unittest import mock


SCRIPT = pathlib.Path(__file__).parents[1] / 'files' / 'check_gpu_readiness'
LOADER = importlib.machinery.SourceFileLoader('check_gpu_readiness', str(SCRIPT))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
GPU_READINESS = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(GPU_READINESS)


class NvidiaSmiCheckTest(unittest.TestCase):
    @mock.patch.object(GPU_READINESS.shutil, 'which', return_value='/usr/bin/nvidia-smi')
    @mock.patch.object(GPU_READINESS, 'run')
    def test_reports_discovered_gpu(self, run_mock, _which_mock):
        run_mock.return_value.stdout = (
            '0, NVIDIA RTX A6000, GPU-example, 535.309.01\n'
        )

        result = GPU_READINESS.nvidia_smi_check()

        self.assertTrue(result['ready'])
        self.assertEqual(result['detail']['count'], 1)
        self.assertEqual(result['detail']['gpus'][0]['name'], 'NVIDIA RTX A6000')

    @mock.patch.object(GPU_READINESS.shutil, 'which', return_value='/usr/bin/nvidia-smi')
    @mock.patch.object(GPU_READINESS, 'run')
    def test_command_failure_is_a_failed_check(self, run_mock, _which_mock):
        run_mock.side_effect = subprocess.CalledProcessError(
            1,
            ['nvidia-smi'],
            stderr='Failed to initialize NVML',
        )

        result = GPU_READINESS.nvidia_smi_check()

        self.assertFalse(result['ready'])
        self.assertIn('NVML', result['detail'])


class ReadinessEvaluationTest(unittest.TestCase):
    def test_missing_required_uvm_fails_readiness(self):
        checks = [
            GPU_READINESS.check('nvidia_smi', True, 'ok'),
            GPU_READINESS.check('module_nvidia_uvm', False, 'not loaded'),
            GPU_READINESS.check('device_nvidia-uvm-tools', False, 'missing', required=False),
        ]

        self.assertFalse(GPU_READINESS.evaluate(checks))

    def test_optional_uvm_tools_device_does_not_fail_readiness(self):
        checks = [
            GPU_READINESS.check('nvidia_smi', True, 'ok'),
            GPU_READINESS.check('module_nvidia_uvm', True, 'loaded'),
            GPU_READINESS.check('device_nvidia-uvm-tools', False, 'missing', required=False),
        ]

        self.assertTrue(GPU_READINESS.evaluate(checks))


class CudaDriverCheckTest(unittest.TestCase):
    class HealthyDriver:
        def cuInit(self, _flags):
            return 0

        def cuDeviceGetCount(self, count):
            count._obj.value = 2
            return 0

    class FailingDriver:
        def cuInit(self, _flags):
            return 3

        def cuGetErrorName(self, _status, name):
            name._obj.value = b'CUDA_ERROR_NOT_INITIALIZED'
            return 0

    def test_cuda_initialization_failure_is_reported(self):
        result = GPU_READINESS.cuda_driver_check(
            loader=lambda _library: self.FailingDriver(),
        )

        self.assertFalse(result['ready'])
        self.assertIn('CUDA_ERROR_NOT_INITIALIZED', result['detail'])

    def test_cuda_device_count_is_reported(self):
        result = GPU_READINESS.cuda_driver_check(
            loader=lambda _library: self.HealthyDriver(),
        )

        self.assertTrue(result['ready'])
        self.assertEqual(result['detail']['device_count'], 2)


if __name__ == '__main__':
    unittest.main()
