#!/bin/bash -l
#SBATCH --job-name="pdstest"
#SBATCH --time=00:05:00
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=1
#SBATCH --output="ex23_twogpus.out"
aprun -n 2 -N 1 -d 1  ./ex23 -pc_type asm -pc_asm_sub_mat_type seqaijviennacl -ksp_monitor -ksp_converged_reason -options_left 1 -log_summary 
