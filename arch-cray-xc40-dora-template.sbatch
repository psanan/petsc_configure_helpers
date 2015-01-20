#!/bin/bash -l
#SBATCH --ntasks=128
#SBATCH --time=1

# Note: add your own custom output file if you need one, with
# something like the following commented-out line
# #SBATCH --output=default.out

export MPICH_VERSION_DISPLAY=1
export MPICH_NEMESIS_ASYNC_PROGRESS=MC
export MPICH_GNI_USE_UNASSIGNED_CPUS=1
export MPICH_MAX_THREAD_SAFETY=multiple
export MPICH_SHARED_MEM_COLL_OPT=1
export MPICH_DMAPP_HW_CE=1
aprun -n128 -j2 -d2 ./ex23 -n 1024 -ksp_type pipecg -ksp_norm_type natural -log_summary -ksp_monitor -ksp_view -pc_type jacobi
