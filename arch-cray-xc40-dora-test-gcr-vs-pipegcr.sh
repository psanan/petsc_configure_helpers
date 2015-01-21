# A convenience script to run GCR vs. PIPEGCR tests (currently) using ex43 and ex49.
# THIS SCRIPT IS WORK IN PROGRESS
# Note that PETSC_ARCH is hardcoded below
# The settings have been copied from the runex19 settings at the time of this writing
# Note that this scripts needs to be run from PETSC_DIR

# bash variables
redColor='\033[0;31m'
noColor='\033[0m' # No Color
alias echo="echo -e"

# Number of tasks, cpus, threads
TASKS=1024
CPUS=2
THREADS=2

# Problem size
MX=512
MY=512

# Environment variables
export MPICH_VERSION_DISPLAY=1 
export MPICH_NEMESIS_ASYNC_PROGRESS=MC
export MPICH_GNI_USE_UNASSIGNED_CPUS=1
export MPICH_MAX_THREAD_SAFETY=multiple
export MPICH_SHARED_MEM_COLL_OPT=1
export MPICH_DMAPP_HW_CE=1

# Build the example binary
echo "--Building examples"
#make -C src/ksp/ksp/examples/tutorials PETSC_DIR=../../../../.. PETSC_ARCH=arch-cray-xc40-dora clean
make -C src/ksp/ksp/examples/tutorials PETSC_DIR=../../../../.. PETSC_ARCH=arch-cray-xc40-dora ex43
#make -C src/ksp/ksp/examples/tutorials PETSC_DIR=../../../../.. PETSC_ARCH=arch-cray-xc40-dora ex49

# First GCR test 
rm -f petsc_ex43_gcr_test1.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test1.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test1.batch
echo '#SBATCH --time=00:00:60' >> petsc_ex43_gcr_test1.batch
echo '#SBATCH --output=petsc_ex43_gcr_test1-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test1.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type gcr -stokes_ksp_gcr_restart 60 -stokes_ksp_rtol 1e-8 -c_str 3 -sinker_eta0 1.0 -sinker_eta1 100 -sinker_dx 0.4 -sinker_dy 0.3 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_pc_type mg -stokes_mg_levels_pc_type fieldsplit -stokes_pc_mg_galerkin -stokes_mg_levels_pc_fieldsplit_block_size 3 -stokes_mg_levels_pc_fieldsplit_0_fields 0,1 -stokes_mg_levels_pc_fieldsplit_1_fields 2 -stokes_mg_levels_fieldsplit_0_pc_type sor -stokes_mg_levels_fieldsplit_1_pc_type sor -stokes_mg_levels_ksp_type chebyshev -stokes_mg_levels_ksp_max_it 1 -stokes_mg_levels_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_pc_mg_levels 4 -stokes_ksp_view -log_summary -options_left' >> petsc_ex43_gcr_test1.batch
#sbatch petsc_ex43_gcr_test1.batch
#rm petsc_ex43_gcr_test1.batch

# Second GCR test 
rm -f petsc_ex43_gcr_test2.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test2.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test2.batch
echo '#SBATCH --time=00:00:60' >> petsc_ex43_gcr_test2.batch
echo '#SBATCH --output=petsc_ex43_gcr_test2-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test2.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type gcr -stokes_ksp_gcr_restart 60 -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type preonly -stokes_fieldsplit_0_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly -stokes_fieldsplit_1_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -log_summary -options_left' >> petsc_ex43_gcr_test2.batch
#sbatch petsc_ex43_gcr_test2.batch
#rm petsc_ex43_gcr_test2.batch

# Third GCR test 
rm -f petsc_ex43_gcr_test3.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test3.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test3.batch
echo '#SBATCH --time=00:00:60' >> petsc_ex43_gcr_test3.batch
echo '#SBATCH --output=petsc_ex43_gcr_test3-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test3.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type gcr -stokes_ksp_gcr_restart 60 -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type preonly -stokes_fieldsplit_0_pc_type ksp -stokes_fieldsplit_0_ksp_ksp_type chebyshev -stokes_fieldsplit_0_ksp_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly  -stokes_fieldsplit_1_pc_type ksp -stokes_fieldsplit_1_ksp_ksp_type chebyshev -stokes_fieldsplit_1_ksp_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_fieldsplit_0_ksp_ksp_monitor_short -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_gcr_test3.batch
sbatch petsc_ex43_gcr_test3.batch
#rm petsc_ex43_gcr_test3.batch

# First PIPEGCR test 
rm -f petsc_ex43_pipegcr_test1.batch
echo '--Running KSP Tutorial 43 pipelined with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test1.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test1.batch
echo '#SBATCH --time=00:00:60' >> petsc_ex43_pipegcr_test1.batch
echo '#SBATCH --output=petsc_ex43_pipegcr_test1-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test1.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type pipegcr -stokes_ksp_pipegcr_mmax 60 -stokes_ksp_norm_type natural -stokes_ksp_rtol 1e-8 -c_str 3 -sinker_eta0 1.0 -sinker_eta1 100 -sinker_dx 0.4 -sinker_dy 0.3 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_pc_type mg -stokes_mg_levels_pc_type fieldsplit -stokes_pc_mg_galerkin -stokes_mg_levels_pc_fieldsplit_block_size 3 -stokes_mg_levels_pc_fieldsplit_0_fields 0,1 -stokes_mg_levels_pc_fieldsplit_1_fields 2 -stokes_mg_levels_fieldsplit_0_pc_type sor -stokes_mg_levels_fieldsplit_1_pc_type sor -stokes_mg_levels_ksp_type chebyshev -stokes_mg_levels_ksp_max_it 1 -stokes_mg_levels_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_pc_mg_levels 4 -stokes_ksp_view -log_summary -options_left' >> petsc_ex43_pipegcr_test1.batch
#sbatch petsc_ex43_pipegcr_test1.batch
#rm petsc_ex43_pipegcr_test1.batch

# Second PIPEGCR test 
rm -f petsc_ex43_pipegcr_test2.batch
echo '--Running KSP Tutorial 43 pipelined with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test2.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test2.batch
echo '#SBATCH --time=00:00:60' >> petsc_ex43_pipegcr_test2.batch
echo '#SBATCH --output=petsc_ex43_pipegcr_test2-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test2.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type pipegcr -stokes_ksp_norm_type natural -stokes_ksp_pipegcr_mmax 60 -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type preonly -stokes_fieldsplit_0_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly -stokes_fieldsplit_1_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -log_summary -options_left' >> petsc_ex43_pipegcr_test2.batch
#sbatch petsc_ex43_pipegcr_test2.batch
#rm petsc_ex43_pipegcr_test2.batch

# Third PIPEGCR test 
rm -f petsc_ex43_pipegcr_test3.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test3.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test3.batch
echo '#SBATCH --time=00:00:60' >> petsc_ex43_pipegcr_test3.batch
echo '#SBATCH --output=petsc_ex43_pipegcr_test3-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test3.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type gcr -stokes_ksp_pipegcr_mmax 60 -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type preonly -stokes_fieldsplit_0_pc_type ksp -stokes_fieldsplit_0_ksp_ksp_type chebyshev -stokes_fieldsplit_0_ksp_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly  -stokes_fieldsplit_1_pc_type ksp -stokes_fieldsplit_1_ksp_ksp_type chebyshev -stokes_fieldsplit_1_ksp_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_fieldsplit_0_ksp_ksp_monitor_short -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_pipegcr_test3.batch
sbatch petsc_ex43_pipegcr_test3.batch
#rm petsc_ex43_pipegcr_test3.batch

echo "--Removing example binaries"
#rm -f src/examples/tutorials/ex43
#rm -f src/examples/tutorials/ex49

echo ''
echo 'Once the jobs are finished, check the output with'
echo '  cat petsc_ex43_gcr_test1-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
echo '  cat petsc_ex43_gcr_test2-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
echo '  cat petsc_ex43_gcr_test3-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
echo '  cat petsc_ex43_pipegcr_test1-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
echo '  cat petsc_ex43_pipegcr_test2-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
echo '  cat petsc_ex43_pipegcr_test3-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
#echo '  cat petsc_ex49_gcr_test1-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
#echo '  cat petsc_ex49_gcr_test2-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
#echo '  cat petsc_ex49_pipegcr_test1-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
#echo '  cat petsc_ex49_pipegcr_test2-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
echo 'or grep for the execution times using'
echo '  grep -C1 "Time (sec):" *gcr*'$TASKS'*'$MX'*'$MY'.out'
echo "${redColor}ALWAYS grep for unused options${noColor}"
echo '  grep -i -C1 "unused options" *gcr*'$TASKS'*'$MX'*'$MY'.out'
echo ''
