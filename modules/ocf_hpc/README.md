# OCF HPC

The `ocf_hpc` module manages the Slurm controller and the `corruption` compute
node. Its GPU resources depend on a coherent NVIDIA stack across the running
kernel, kernel modules, device nodes, userspace driver libraries, and job
runtime.

## GPU readiness

`nvidia-smi` is necessary but not sufficient evidence that CUDA jobs can run.
It exercises NVIDIA's management library, while CUDA applications also require
the Unified Virtual Memory (UVM) module and device, a loadable `libcuda.so.1`,
and successful CUDA Driver API initialization.

Run the read-only readiness probe after a reboot, driver change, kernel change,
or suspected GPU failure:

```console
sudo /usr/local/sbin/check-ocf-gpu-readiness
```

The probe writes a JSON report and exits zero only when all required checks
pass. It does not load modules, modify packages, change Slurm state, or require
a user Python environment. The optional `/dev/nvidia-uvm-tools` check is
reported but does not determine readiness.

The probe verifies:

- `nvidia-smi` can enumerate at least one GPU;
- the `nvidia` and `nvidia_uvm` modules are loaded;
- control, UVM, and physical GPU character devices exist;
- `libcuda.so.1` loads and its Driver API can initialize and enumerate devices;
- installed NVIDIA package versions are captured for diagnosis.

## Safe driver or kernel update

Avoid changing one NVIDIA library or package independently. The Linux CUDA
stack spans kernel and userspace components, and a partial upgrade or rollback
can leave management queries working while compute initialization fails.

1. Drain the compute node before changing the kernel or NVIDIA packages.
2. Record the current kernel, loaded modules, package sources, package versions,
   GPU inventory, and a passing readiness report.
3. Use one package-management path and one coherent driver branch. Do not mix
   distribution packages, NVIDIA repository packages, and runfile installs.
4. Confirm headers for the target kernel are present and the NVIDIA DKMS build
   succeeds before rebooting.
5. Reboot so the running modules and userspace libraries come from the intended
   installation.
6. Run the readiness probe directly on the node.
7. Run a Slurm canary that initializes CUDA and performs a small allocation in
   a maintained GPU environment.
8. Resume the node only after both checks pass.

NVIDIA recommends package-manager installation, matching kernel headers, and
post-installation verification. See the
[NVIDIA Driver Installation Guide](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/latest/index.html)
and its [kernel-module reference](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/kernel-modules.html).

## Failure isolation

Capture diagnostics before attempting another package change:

```console
uname -r
nvidia-smi
lsmod | grep '^nvidia'
ls -l /dev/nvidia*
cat /proc/driver/nvidia/version
dkms status
dpkg-query -W 'nvidia-*' 'libnvidia-*'
apt-cache policy nvidia-driver nvidia-kernel-dkms libcuda1
sudo /usr/local/sbin/check-ocf-gpu-readiness
```

Interpret common states as follows:

| Observation | Likely boundary |
| --- | --- |
| `nvidia-smi` fails | Base module, NVML, device access, or kernel/userspace mismatch |
| `nvidia-smi` passes but `nvidia_uvm` is absent | Compute path is incomplete even though management works |
| UVM exists but `cuInit` fails | Driver library, device access, or module/library coherence |
| Direct probe passes but a Slurm job fails | Slurm GRES/cgroup configuration or job environment |
| CUDA Driver API passes but one framework fails | User environment or framework compatibility |

If recovery requires rollback, restore the kernel, NVIDIA modules, userspace
driver libraries, and package-source policy as one tested set. Reverting only
`nvidia-smi` or one library does not restore a coherent compute stack.

## Deployment boundaries

This module is included by `hieradata/nodes/corruption.yaml`; the controller is
declared separately in `hieradata/nodes/segfault.yaml`. Changes here should not
be generalized into `ocf_desktop` or other service roles without a separate
review.

Test changes in a personal Puppet environment and review the octocatalog diff
before applying them to `corruption`. The initial readiness probe is manual and
read-only by design. A future change may integrate it with Slurm's
`HealthCheckProgram` or monitoring, but automatic drain/resume behavior should
be reviewed independently because the health program must explicitly perform
those state changes. See the
[Slurm health-check configuration](https://slurm.schedmd.com/slurm.conf.html).
