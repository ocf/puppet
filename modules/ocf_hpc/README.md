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
| GPU memory remains allocated with no Slurm job or live PID | Stale CUDA context, orphaned process, or driver bookkeeping |

## Stale GPU memory recovery

Treat unexplained GPU memory as an incident until it is correlated with a
Slurm allocation or a live process. A process shown as `[Not Found]` by
`nvidia-smi` is evidence for a stale driver context, but is not sufficient by
itself to reset a device. Capture evidence first and avoid disrupting valid
workloads.

From the controller, confirm that the node and GPU are not allocated:

```console
squeue -w corruption
sacct --starttime today --state=RUNNING,PENDING \
  --format=JobID,JobName,User,State,NodeList,AllocTRES
scontrol show node corruption
```

From a Slurm allocation on `corruption`, record the visible GPU UUID, memory,
and process accounting:

```console
nvidia-smi -L
nvidia-smi \
  --query-gpu=index,uuid,name,memory.total,memory.used,memory.free,utilization.gpu,compute_mode,persistence_mode \
  --format=csv,noheader
nvidia-smi \
  --query-compute-apps=gpu_uuid,pid,process_name,used_gpu_memory \
  --format=csv,noheader
nvidia-smi pmon -c 1
```

If memory remains assigned after the corresponding Slurm job has ended, drain
the node before host-level investigation:

```console
sudo scontrol update NodeName=corruption State=DRAIN \
  Reason="Investigating unexplained GPU memory"
squeue -w corruption
```

On `corruption`, use the reported PID and GPU UUID to distinguish a live
process from stale accounting. These checks require administrator access to
avoid process-visibility restrictions:

```console
sudo nvidia-smi
sudo nvidia-smi \
  --query-compute-apps=gpu_uuid,pid,process_name,used_gpu_memory \
  --format=csv
sudo ps -fp PID
sudo fuser -v /dev/nvidia*
sudo lsof /dev/nvidia*
sudo systemctl status nvidia-persistenced
sudo journalctl -u nvidia-persistenced -b --no-pager
sudo dmesg -T | grep -Ei 'NVRM|Xid|nvidia'
```

Do not kill a process or reset a GPU until its Slurm ownership and purpose are
known. If the PID is absent from `/proc`, no job owns the GPU, and no peer GPU
or display workload depends on it, an administrator may attempt a targeted
reset using the UUID reported by `nvidia-smi`:

```console
sudo nvidia-smi --gpu-reset -i GPU_UUID
```

Some device topologies or driver failures do not support an isolated reset. If
the reset is rejected or memory remains allocated, reboot the drained compute
node instead of repeatedly changing packages or killing unrelated processes.
Restarting `nvidia-persistenced` may repair service state, but does not prove
that an orphaned CUDA context has been released.

After reset or reboot, require all of the following before resuming the node:

1. Idle memory is back to the expected baseline on every GPU.
2. `/usr/local/sbin/check-ocf-gpu-readiness` exits successfully.
3. A Slurm GPU canary initializes CUDA and completes a synchronized operation.
4. The canary process disappears and its allocated memory is released.
5. No new NVIDIA Xid errors appear in the kernel log.

Only then return the node to service:

```console
sudo scontrol update NodeName=corruption State=RESUME
```

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
