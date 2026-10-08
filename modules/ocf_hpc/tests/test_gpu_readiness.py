"""Hardware-independent tests; only ProcessTimeoutTest starts a local Python child."""
import contextlib
import ctypes
import importlib.machinery
import importlib.util
import io
import json
import pathlib
import stat
import subprocess
import sys
import unittest
from unittest import mock


SCRIPT = pathlib.Path(__file__).parents[1] / 'files' / 'check_gpu_readiness'
LOADER = importlib.machinery.SourceFileLoader('check_gpu_readiness', str(SCRIPT))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
GPU = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(GPU)
SMI_OUTPUT = '0, RTX A6000, GPU-first, 535.example\n1, RTX A6000, GPU-second, 535.example\n'


class HardwareFreeTest(unittest.TestCase):
    def setUp(self):
        # An accidental call to an actual command or driver must fail the test.
        self.enter_patch(GPU.subprocess, 'run', side_effect=AssertionError('real command forbidden'))
        self.enter_patch(GPU.ctypes, 'CDLL', side_effect=AssertionError('real CUDA load forbidden'))

    def enter_patch(self, target, name, **kwargs):
        patcher = mock.patch.object(target, name, **kwargs)
        value = patcher.start()
        self.addCleanup(patcher.stop)
        return value

    def command_output(self, output):
        self.enter_patch(GPU.shutil, 'which', side_effect=lambda command: '/mock/' + command)
        return self.enter_patch(GPU, 'run', return_value=mock.Mock(stdout=output))


class NvidiaInventoryTest(HardwareFreeTest):
    def test_valid_inventory(self):
        self.command_output(SMI_OUTPUT)
        result = GPU.nvidia_smi_check()
        self.assertTrue(result['ready'])
        self.assertEqual([gpu['index'] for gpu in result['detail']['gpus']], ['0', '1'])

    def test_quoted_name_and_byte_output(self):
        self.command_output(b'2,"GPU, example",GPU-third,535.example\n')
        result = GPU.nvidia_smi_check()
        self.assertTrue(result['ready'])
        self.assertEqual(result['detail']['gpus'][0]['name'], 'GPU, example')

    def test_malformed_or_empty_inventory_fails(self):
        run = self.command_output('')
        for value in ['', '\n', 'invalid', '0,name,GPU-id', '-1,name,GPU-id,v',
                      'x,name,GPU-id,v', '0,,GPU-id,v', '0,name,,v', '0,name,GPU-id,',
                      '0,name,GPU-id,v,extra', '0,"unterminated,GPU-id,v',
                      '0,name,GPU-id,v\n0,name,GPU-other,v',
                      '0,name,GPU-id,v\n1,name,GPU-id,v']:
            with self.subTest(value=value):
                run.return_value.stdout = value
                self.assertFalse(GPU.nvidia_smi_check()['ready'])

    def test_missing_command(self):
        self.enter_patch(GPU.shutil, 'which', return_value=None)
        self.assertFalse(GPU.nvidia_smi_check()['ready'])

    def test_command_failures_remain_json_serializable(self):
        run = self.command_output('')
        errors = [FileNotFoundError('removed after lookup'), PermissionError('denied')]
        for output in [b'error\xff', 'error', None]:
            errors.extend([
                subprocess.TimeoutExpired(['nvidia-smi'], 10, stderr=output),
                subprocess.CalledProcessError(1, ['nvidia-smi'], stderr=output),
            ])
        for error in errors:
            with self.subTest(error=error):
                run.side_effect = error
                result = GPU.nvidia_smi_check()
                self.assertFalse(result['ready'])
                self.assertIsInstance(result['detail'], str)
                json.dumps(result)


class DeviceTest(HardwareFreeTest):
    def test_module_presence(self):
        exists = self.enter_patch(GPU.os.path, 'isdir', return_value=False)
        self.assertFalse(GPU.kernel_module_check('nvidia_uvm')['ready'])
        exists.return_value = True
        self.assertTrue(GPU.kernel_module_check('nvidia_uvm')['ready'])

    def test_device_access_and_type(self):
        access = self.enter_patch(GPU.os, 'stat', return_value=mock.Mock(st_mode=stat.S_IFCHR))
        self.assertTrue(GPU.character_device_check('/dev/nvidiactl')['ready'])
        access.return_value.st_mode = stat.S_IFREG
        self.assertFalse(GPU.character_device_check('/dev/nvidiactl')['ready'])
        access.side_effect = PermissionError('denied')
        result = GPU.character_device_check('/dev/nvidia-uvm-tools', required=False)
        self.assertFalse(result['ready'])
        self.assertFalse(result['required'])
        json.dumps(result)

    def test_inventory_rejects_bad_nodes_and_duplicate_indices(self):
        paths = self.enter_patch(GPU.glob, 'glob', return_value=[])
        access = self.enter_patch(GPU.os, 'stat', return_value=mock.Mock(st_mode=stat.S_IFCHR))
        self.assertFalse(GPU.gpu_device_check()['ready'])
        paths.return_value = ['/dev/nvidia1', '/dev/nvidia0', '/dev/nvidia0-extra']
        self.assertEqual(GPU.gpu_device_check()['detail']['indices'], [0, 1])
        paths.return_value = ['/dev/nvidia0', '/dev/nvidia00']
        self.assertFalse(GPU.gpu_device_check()['ready'])
        paths.return_value = ['/dev/nvidia0']
        access.return_value.st_mode = stat.S_IFREG
        self.assertFalse(GPU.gpu_device_check()['ready'])
        access.side_effect = FileNotFoundError('gone')
        self.assertFalse(GPU.gpu_device_check()['ready'])


class CudaWorkerTest(HardwareFreeTest):
    def driver(self, count=2, init_status=0, count_status=0):
        def device_count(pointer):
            pointer._obj.value = count
            return count_status

        def error_name(_status, pointer):
            pointer._obj.value = b'CUDA_ERROR_EXAMPLE'
            return 0

        return mock.Mock(
            cuInit=mock.Mock(return_value=init_status),
            cuDeviceGetCount=mock.Mock(side_effect=device_count),
            cuGetErrorName=mock.Mock(side_effect=error_name),
        )

    def test_success_and_native_signatures(self):
        driver = self.driver()
        result = GPU.cuda_worker(loader=lambda _name: driver)
        self.assertTrue(result['ready'])
        self.assertEqual(result['detail']['device_count'], 2)
        self.assertEqual(driver.cuInit.argtypes, [ctypes.c_uint])
        self.assertEqual(driver.cuDeviceGetCount.argtypes, [ctypes.POINTER(ctypes.c_int)])
        self.assertEqual(driver.cuGetErrorName.argtypes,
                         [ctypes.c_int, ctypes.POINTER(ctypes.c_char_p)])
        for name in ['cuInit', 'cuDeviceGetCount', 'cuGetErrorName']:
            self.assertIs(getattr(driver, name).restype, ctypes.c_int)

    def test_init_count_and_zero_device_failures(self):
        for kwargs in [dict(init_status=3), dict(count_status=3), dict(count=0)]:
            with self.subTest(kwargs=kwargs):
                result = GPU.cuda_worker(loader=lambda _name: self.driver(**kwargs))
                self.assertFalse(result['ready'])
                json.dumps(result)

    def test_missing_library_and_symbols(self):
        result = GPU.cuda_worker(loader=mock.Mock(side_effect=OSError('missing library')))
        self.assertFalse(result['ready'])
        for name in ['cuInit', 'cuDeviceGetCount', 'cuGetErrorName']:
            driver = self.driver()
            delattr(driver, name)
            with self.subTest(name=name):
                self.assertFalse(GPU.cuda_worker(loader=lambda _name: driver)['ready'])

    def test_error_name_falls_back_to_numeric_status(self):
        driver = self.driver(init_status=3)
        driver.cuGetErrorName.side_effect = None
        driver.cuGetErrorName.return_value = 1
        result = GPU.cuda_worker(loader=lambda _name: driver)
        self.assertIn('CUDA_ERROR_3', result['detail'])


class CudaParentTest(HardwareFreeTest):
    def test_child_command_and_success(self):
        run = self.command_output(json.dumps(GPU.check('cuda_driver_api', True, dict(device_count=2))))
        self.assertTrue(GPU.cuda_driver_check()['ready'])
        command = run.call_args[0][0]
        self.assertEqual(command[0], sys.executable)
        self.assertEqual(command[-1], '--cuda-worker')

    def test_child_reported_failure(self):
        self.command_output(json.dumps(GPU.check('cuda_driver_api', False, 'driver unavailable')))
        self.assertFalse(GPU.cuda_driver_check()['ready'])

    def test_malformed_child_output(self):
        run = self.command_output('')
        values = ['', 'not json', '[]', 'null', '{}', '{"ready": true}',
                  '{"ready": "yes", "detail": {}}',
                  '{"ready": true, "detail": {"device_count": true}}',
                  '{"ready": true, "detail": {"device_count": 0}}',
                  '{"ready": true, "detail": {"device_count": "2"}}',
                  '{"ready": true, "detail": "bad"}',
                  '{"ready": false, "detail": null}']
        for value in values:
            with self.subTest(value=value):
                run.return_value.stdout = value
                self.assertFalse(GPU.cuda_driver_check()['ready'])

    def test_child_crash_timeout_and_spawn_failure(self):
        run = self.command_output('')
        for error in [subprocess.CalledProcessError(-11, ['python']),
                      subprocess.TimeoutExpired(['python'], 10, stderr=b'partial'),
                      FileNotFoundError('interpreter unavailable')]:
            with self.subTest(error=error):
                run.side_effect = error
                result = GPU.cuda_driver_check()
                self.assertFalse(result['ready'])
                json.dumps(result)


class PackageTest(HardwareFreeTest):
    def test_valid_text_and_bytes(self):
        run = self.command_output('')
        for output in ['libcuda1\t535.example\n', b'libcuda1\t535.example\n']:
            run.return_value.stdout = output
            self.assertTrue(GPU.package_diagnostics()['available'])
        self.assertIn('libcuda1', run.call_args[0][0])

    def test_missing_or_malformed_inventory(self):
        run = self.command_output('')
        for output in ['', 'not tab separated', 'libcuda1\t', 'libcuda1\tv\textra']:
            run.return_value.stdout = output
            self.assertFalse(GPU.package_diagnostics()['available'])
        self.enter_patch(GPU.shutil, 'which', return_value=None)
        self.assertFalse(GPU.package_diagnostics()['available'])

    def test_failures_are_nonfatal_and_serializable(self):
        run = self.command_output('')
        errors = [OSError('failed'), subprocess.CalledProcessError(1, ['dpkg-query'])]
        errors.extend(subprocess.TimeoutExpired(['dpkg-query'], 10, output=output)
                      for output in [b'libcuda1\t535.example\n', 'partial', None])
        for error in errors:
            run.side_effect = error
            result = GPU.package_diagnostics()
            self.assertFalse(result['available'])
            json.dumps(result)


class InventoryTest(HardwareFreeTest):
    def test_inventory_contract(self):
        for smi_indices, device_indices, count, expected, ready in [
            ([0, 1], [1, 0], 2, None, True),
            ([0, 1], [0, 1], 2, 2, True),
            ([0, 1], [0, 1], 2, 3, False),
            ([0, 1, 2], [0, 1], 1, None, False),
            ([0, 1], [0, 2], 2, None, False),
            ([0, 1], [0, 1], 1, None, False),
        ]:
            with self.subTest(smi=smi_indices, devices=device_indices, cuda=count, expected=expected):
                smi = GPU.check('smi', True, dict(gpus=[dict(index=i) for i in smi_indices]))
                devices = GPU.check('devices', True, dict(indices=device_indices))
                cuda = GPU.check('cuda', True, dict(device_count=count))
                self.assertEqual(GPU.inventory_check(smi, devices, cuda, expected)['ready'], ready)

    def test_failed_prerequisite(self):
        failed = GPU.check('unknown', False, 'unavailable')
        self.assertFalse(GPU.inventory_check(failed, failed, failed, None)['ready'])


class ReportTest(HardwareFreeTest):
    def setUp(self):
        super().setUp()
        self.enter_patch(GPU.shutil, 'which', side_effect=lambda name: '/mock/' + name)
        self.runner = self.enter_patch(GPU, 'run', side_effect=self.response)
        self.enter_patch(GPU.os.path, 'isdir', return_value=True)
        self.enter_patch(GPU.os, 'stat', return_value=mock.Mock(st_mode=stat.S_IFCHR))
        self.enter_patch(GPU.glob, 'glob', return_value=['/dev/nvidia0', '/dev/nvidia1'])

    def response(self, command):
        if command[0].endswith('nvidia-smi'):
            return mock.Mock(stdout=SMI_OUTPUT)
        if command[0].endswith('dpkg-query'):
            raise subprocess.TimeoutExpired(command, 10, output=b'partial')
        return mock.Mock(stdout=json.dumps(GPU.check('cuda', True, dict(device_count=2))))

    def test_complete_success_despite_package_failure(self):
        report = GPU.probe(2)
        self.assertTrue(report['ready'])
        self.assertEqual(report['scope'], 'basic_cuda_driver')
        self.assertEqual(report['schema_version'], 1)
        self.assertEqual(report['expected_gpu_count'], 2)
        self.assertFalse(report['diagnostics']['packages']['available'])
        json.dumps(report)

    def test_optional_device_does_not_fail_report(self):
        def device(path):
            if path == '/dev/nvidia-uvm-tools':
                raise FileNotFoundError(path)
            return mock.Mock(st_mode=stat.S_IFCHR)

        self.enter_patch(GPU.os, 'stat', side_effect=device)
        self.assertTrue(GPU.probe()['ready'])

    def test_required_module_fails_report(self):
        self.enter_patch(GPU.os.path, 'isdir', return_value=False)
        self.assertFalse(GPU.probe()['ready'])

    def test_complete_timeout_report(self):
        self.runner.side_effect = subprocess.TimeoutExpired(['mock'], 10, stderr=b'partial\xff')
        report = GPU.probe()
        self.assertFalse(report['ready'])
        json.dumps(report)

    def test_cli_output_and_exit_codes(self):
        for args, expected in [([], 0), (['--compact', '--expected-gpus', '2'], 0),
                               (['--expected-gpus', '3'], 1)]:
            with self.subTest(args=args), contextlib.redirect_stdout(io.StringIO()) as output:
                self.assertEqual(GPU.main(args), expected)
                report = json.loads(output.getvalue())
                self.assertEqual(report['ready'], expected == 0)
                if '--compact' in args:
                    self.assertEqual(len(output.getvalue().splitlines()), 1)

    def test_invalid_cli_arguments_exit_two_before_probe(self):
        for args in [['--expected-gpus', value] for value in ['0', '-1', '1.5', 'abc']] + [['--unknown']]:
            with self.subTest(args=args), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as raised:
                    GPU.main(args)
                self.assertEqual(raised.exception.code, 2)
        self.runner.assert_not_called()

    def test_internal_worker_does_not_run_full_probe(self):
        self.enter_patch(GPU, 'cuda_worker', return_value=GPU.check('cuda', False, 'unavailable'))
        with contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(GPU.main(['--cuda-worker']), 0)
            self.assertFalse(json.loads(output.getvalue())['ready'])
        self.runner.assert_not_called()


class ProcessTimeoutTest(unittest.TestCase):
    def test_default_command_timeout_is_ten_seconds(self):
        with mock.patch.object(subprocess, 'run') as runner:
            GPU.run(['mock-command'])
        self.assertEqual(runner.call_args[1]['timeout'], 10)
        self.assertTrue(runner.call_args[1]['check'])

    def test_timeout_kills_and_reaps_harmless_child(self):
        children = []
        popen = subprocess.Popen

        def record_child(*args, **kwargs):
            child = popen(*args, **kwargs)
            children.append(child)
            return child

        with mock.patch.object(subprocess, 'Popen', side_effect=record_child):
            with self.assertRaises(subprocess.TimeoutExpired):
                GPU.run([sys.executable, '-c', 'import time; time.sleep(30)'], timeout=0.1)
        self.assertEqual(len(children), 1)
        self.assertIsNotNone(children[0].returncode)
        self.assertIsNotNone(children[0].poll())


if __name__ == '__main__':
    unittest.main()
