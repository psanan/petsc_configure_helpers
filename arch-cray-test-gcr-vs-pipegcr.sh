# A convenience script to run GCR vs. PIPEGCR tests (currently) using ex43 and ex49.
# THIS SCRIPT IS WORK IN PROGRESS
# Note that PETSC_ARCH is hardcoded below
# The settings have been copied from the runex19 settings at the time of this writing
# Note that this scripts needs to be run from PETSC_DIR

# bash variables
redColor="\033[0;31m"
redBoldColor="\033[1;31m"
noColor='\033[0m'
alias echo="echo -e"

echo "${redBoldColor}===========================================================================${noColor}"
echo "${redBoldColor}= DO NOT RUN THIS SCRIPT ON A DIFFERENT MACHINE BEFORE JOBS ARE SUBMITTED =${noColor}"
echo "${redBoldColor}===========================================================================${noColor}"

# Number of tasks, cpus, threads
TASKS=1024
CPUS=2
THREADS=2
TIME=2 # job time in minutes
MACHINENAME=`echo $HOSTNAME|sed -r 's/[0-9]{1,10}$//'`
if [ $MACHINENAME == dora ]
then
    ARCH=xc40
else
    ARCH=xc30
fi;

# Problem size
MX=4096
MY=4096

# Solver settings
OLDDIRS=60

# which tests to run
GCR1=false
GCR2=false
GCR3=false
GCR4=false
GCR5=false
GCR6=false
GCR7=true
PGCR1=false
PGCR2=false
PGCR3=false
PGCR4=false
PGCR5=false
PGCR6=false
PGCR7=true

# Environment variables
export MPICH_VERSION_DISPLAY=1 
export MPICH_NEMESIS_ASYNC_PROGRESS=MC
export MPICH_GNI_USE_UNASSIGNED_CPUS=1
export MPICH_MAX_THREAD_SAFETY=multiple
export MPICH_SHARED_MEM_COLL_OPT=1
export MPICH_DMAPP_HW_CE=1

# create output dir
mkdir -p out

# Build the example binary
echo "--Building examples"
make -C src/ksp/ksp/examples/tutorials PETSC_DIR=../../../../.. PETSC_ARCH=arch-cray-$ARCH-$MACHINENAME clean
make -C src/ksp/ksp/examples/tutorials PETSC_DIR=../../../../.. PETSC_ARCH=arch-cray-$ARCH-$MACHINENAME ex43
#make -C src/ksp/ksp/examples/tutorials PETSC_DIR=../../../../.. PETSC_ARCH=arch-cray-$ARCH-$MACHINENAME ex49

# First GCR test 
if [ $GCR1 == true ]; then
rm -f petsc_ex43_gcr_test1.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test1.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test1.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_gcr_test1.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05' >> petsc_ex43_gcr_test1.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_gcr_test1-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test1.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8 -c_str 3 -sinker_eta0 1.0 -sinker_eta1 100 -sinker_dx 0.4 -sinker_dy 0.3 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_pc_type mg -stokes_mg_levels_pc_type fieldsplit -stokes_pc_mg_galerkin -stokes_mg_levels_pc_fieldsplit_block_size 3 -stokes_mg_levels_pc_fieldsplit_0_fields 0,1 -stokes_mg_levels_pc_fieldsplit_1_fields 2 -stokes_mg_levels_fieldsplit_0_pc_type sor -stokes_mg_levels_fieldsplit_1_pc_type sor -stokes_mg_levels_ksp_type chebyshev -stokes_mg_levels_ksp_max_it 1 -stokes_mg_levels_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_pc_mg_levels 4 -stokes_ksp_view -log_summary -options_left' >> petsc_ex43_gcr_test1.batch
sbatch petsc_ex43_gcr_test1.batch
rm petsc_ex43_gcr_test1.batch
fi;

# Second GCR test 
if [ $GCR2 == true ]; then
rm -f petsc_ex43_gcr_test2.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test2.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test2.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_gcr_test2.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05' >> petsc_ex43_gcr_test2.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_gcr_test2-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test2.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 \
-stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8  -stokes_ksp_converged_reason -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type cg -stokes_fieldsplit_0_ksp_rtol 1e-5 -stokes_fieldsplit_0_pc_type ksp -stokes_fieldsplit_0_ksp_ksp_type preonly -stokes_fieldsplit_0_ksp_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly -stokes_fieldsplit_1_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -log_summary -options_left' >> petsc_ex43_gcr_test2.batch
sbatch petsc_ex43_gcr_test2.batch
rm petsc_ex43_gcr_test2.batch
fi;
#-stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type cg -stokes_fieldsplit_0_pc_type ksp -stokes_fieldsplit_0_ksp_ksp_type preonly -stokes_fieldsplit_0_ksp_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly -stokes_fieldsplit_1_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -log_summary -options_left' >> petsc_ex43_gcr_test2.batch

# Third GCR test 
if [ $GCR3 == true ]; then
rm -f petsc_ex43_gcr_test3.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test3.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test3.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_gcr_test3.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_gcr_test3.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_gcr_test3-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test3.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS'  -stokes_ksp_converged_reason -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type preonly -stokes_fieldsplit_0_pc_type ksp -stokes_fieldsplit_0_ksp_ksp_type chebyshev -stokes_fieldsplit_0_ksp_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly  -stokes_fieldsplit_1_pc_type ksp -stokes_fieldsplit_1_ksp_ksp_type chebyshev -stokes_fieldsplit_1_ksp_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_fieldsplit_0_ksp_ksp_monitor_short -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_gcr_test3.batch
sbatch petsc_ex43_gcr_test3.batch
rm petsc_ex43_gcr_test3.batch
fi;

# 4th GCR test using settings suggested by Dave
if [ $GCR4 == true ]; then
rm -f petsc_ex43_gcr_test4.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test4.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test4.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_gcr_test4.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_gcr_test4.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_gcr_test4-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test4.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8  -stokes_ksp_converged_reason		\
-stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE	\
-stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2							\
-stokes_fieldsplit_0_ksp_type gcr											\
-stokes_fieldsplit_0_ksp_max_it 300											\
-stokes_fieldsplit_0_ksp_gcr_restart '$OLDDIRS'										\
-stokes_fieldsplit_0_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_0_ksp_monitor_short											\
-stokes_fieldsplit_0_pc_type asm											\
-stokes_fieldsplit_0_pc_asm_overlap 4											\
-stokes_fieldsplit_1_ksp_type gcr											\
-stokes_fieldsplit_1_ksp_max_it 300											\
-stokes_fieldsplit_1_ksp_gcr_restart '$OLDDIRS'										\
-stokes_fieldsplit_1_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_1_ksp_monitor_short											\
-stokes_fieldsplit_1_pc_type asm											\
-stokes_fieldsplit_1_pc_asm_overlap 4											\
-c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2							\
-mx '$MX' -my '$MY'													\
-stokes_ksp_monitor_short  -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_gcr_test4.batch
sbatch petsc_ex43_gcr_test4.batch
rm petsc_ex43_gcr_test4.batch
fi;

# 5th GCR test using 'heavier' settings suggested by Dave
if [ $GCR5 == true ]; then
rm -f petsc_ex43_gcr_test5.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test5.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test5.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_gcr_test5.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_gcr_test5.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_gcr_test5-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test5.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8						\
-stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE	\
-stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2							\
-stokes_fieldsplit_0_ksp_type gcr											\
-stokes_fieldsplit_0_ksp_max_it 300											\
-stokes_fieldsplit_0_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_0_ksp_gcr_restart '$OLDDIRS'										\
-stokes_fieldsplit_0_ksp_monitor_short											\
-stokes_fieldsplit_0_pc_type asm											\
-stokes_fieldsplit_0_pc_asm_overlap 4											\
-stokes_fieldsplit_0_sub_pc_factor_fill 4										\
-stokes_fieldsplit_1_ksp_type gcr											\
-stokes_fieldsplit_1_ksp_max_it 300											\
-stokes_fieldsplit_1_ksp_gcr_restart '$OLDDIRS'										\
-stokes_fieldsplit_1_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_1_ksp_monitor_short											\
-stokes_fieldsplit_1_pc_type asm											\
-stokes_fieldsplit_1_pc_asm_overlap 4											\
-stokes_fieldsplit_1_sub_pc_factor_fill 4										\
-c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2							\
-mx '$MX' -my '$MY'													\
-stokes_ksp_monitor_short  -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_gcr_test5.batch
sbatch petsc_ex43_gcr_test5.batch
rm petsc_ex43_gcr_test5.batch
fi;

# 6th GCR test using 'heavier' settings suggested by Dave using lu as PC
if [ $GCR6 == true ]; then
rm -f petsc_ex43_gcr_test6.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test6.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test6.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_gcr_test6.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_gcr_test6.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_gcr_test6-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test6.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8  -stokes_ksp_converged_reason		\
-stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE	\
-stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2							\
-stokes_fieldsplit_0_ksp_type gcr											\
-stokes_fieldsplit_0_ksp_max_it 300											\
-stokes_fieldsplit_0_ksp_gcr_restart '$OLDDIRS'										\
-stokes_fieldsplit_0_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_0_ksp_monitor_short											\
-stokes_fieldsplit_0_pc_type asm											\
-stokes_fieldsplit_0_pc_asm_overlap 4											\
-stokes_fieldsplit_0_sub_pc_type lu											\
-stokes_fieldsplit_1_ksp_type gcr											\
-stokes_fieldsplit_1_ksp_max_it 300											\
-stokes_fieldsplit_1_ksp_gcr_restart '$OLDDIRS'										\
-stokes_fieldsplit_1_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_1_ksp_monitor_short											\
-stokes_fieldsplit_1_pc_type asm											\
-stokes_fieldsplit_1_pc_asm_overlap 4											\
-stokes_fieldsplit_1_sub_pc_type lu											\
-c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2							\
-mx '$MX' -my '$MY'													\
-stokes_ksp_monitor_short  -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_gcr_test6.batch
sbatch petsc_ex43_gcr_test6.batch
rm petsc_ex43_gcr_test6.batch
fi;

# 7th GCR test using settings suggested by Patrick
if [ $GCR7 == true ]; then
rm -f petsc_ex43_gcr_test7.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_gcr_test7.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_gcr_test7.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_gcr_test7.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_gcr_test7.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_gcr_test7-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_gcr_test7.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-options_left 1 \
-stokes_ksp_monitor \
-stokes_ksp_view \
-stokes_ksp_converged_reason \
-sinker_eta0 1.0e-2 -sinker_eta1 1.0e2 \
-stokes_ksp_type gcr \
-stokes_ksp_rtol 1e-06 \
-stokes_ksp_max_it 399 \
-stokes_pc_type fieldsplit \
-stokes_pc_use_amat \
-stokes_pc_fieldsplit_type schur \
-stokes_pc_fieldsplit_schur_fact_type upper \
-stokes_fieldsplit_p_ksp_type preonly \
-stokes_fieldsplit_p_pc_type bjacobi \
-stokes_fieldsplit_u_ksp_monitor \
-stokes_fieldsplit_u_ksp_rtol 1e-1 \
-stokes_fieldsplit_u_pc_type mg \
-stokes_fieldsplit_u_pc_mg_log \
-stokes_fieldsplit_u_mg_coarse_pc_type lu \
-stokes_fieldsplit_u_mg_coarse_pc_factor_mat_solver_package mumps \
-stokes_fieldsplit_u_pc_mg_galerkin \
-stokes_fieldsplit_u_pc_mg_levels 4 \
-stokes_fieldsplit_u_mg_levels_3_pc_type asm \
-stokes_fieldsplit_u_mg_levels_3_ksp_type fgmres \
-stokes_fieldsplit_u_mg_levels_3_ksp_max_it 1 \
-stokes_fieldsplit_u_mg_levels_3_pc_asm_type restrict \
-stokes_fieldsplit_u_mg_levels_3_sub_pc_type  ilu \
-stokes_fieldsplit_u_mg_levels_3_pc_asm_dm_subdomains 1 \
-stokes_fieldsplit_u_mg_levels_3_pc_asm_overlap 4 \
-stokes_fieldsplit_u_mg_levels_1_ksp_type chebyshev -stokes_fieldsplit_u_mg_levels_1_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_fieldsplit_u_mg_levels_1_est_ksp_norm_type none \
-stokes_fieldsplit_u_mg_levels_1_est_ksp_max_it 6 \
-stokes_fieldsplit_u_mg_levels_1_fieldsplit_0_ksp_max_it 15 \
-stokes_fieldsplit_u_mg_levels_1_fieldsplit_0_pc_type jacobi -stokes_fieldsplit_u_mg_levels_1_fieldsplit_0_ksp_norm_type none \
-stokes_fieldsplit_u_mg_levels_2_ksp_type chebyshev -stokes_fieldsplit_u_mg_levels_2_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_fieldsplit_u_mg_levels_2_est_ksp_norm_type none \
-stokes_fieldsplit_u_mg_levels_2_est_ksp_max_it 6 \
-stokes_fieldsplit_u_mg_levels_2_fieldsplit_0_ksp_max_it 15 \
-stokes_fieldsplit_u_mg_levels_2_fieldsplit_0_pc_type jacobi -stokes_fieldsplit_u_mg_levels_2_fieldsplit_0_ksp_norm_type none \
-da_refine_x 4 -da_refine_y 4 \
-c_str 2 \
-mx '$MX' -my '$MY >> petsc_ex43_gcr_test7.batch
sbatch petsc_ex43_gcr_test7.batch
rm petsc_ex43_gcr_test7.batch
fi;

# ===================================================================================================
# PIPEGCR
# ===================================================================================================
# First PIPEGCR test 
if [ $PGCR1 == true ]; then
rm -f petsc_ex43_pipegcr_test1.batch
echo '--Running KSP Tutorial 43 pipelined with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test1.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test1.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_pipegcr_test1.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_pipegcr_test1.batch; fi
echo '#SBATCH --output=out/petsc_ex43_pipegcr_test1-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test1.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type pipegcr -stokes_ksp_pipegcr_mmax '$OLDDIRS' -stokes_ksp_norm_type natural -stokes_ksp_rtol 1e-8 -c_str 3 -sinker_eta0 1.0 -sinker_eta1 100 -sinker_dx 0.4 -sinker_dy 0.3 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_pc_type mg -stokes_mg_levels_pc_type fieldsplit -stokes_pc_mg_galerkin -stokes_mg_levels_pc_fieldsplit_block_size 3 -stokes_mg_levels_pc_fieldsplit_0_fields 0,1 -stokes_mg_levels_pc_fieldsplit_1_fields 2 -stokes_mg_levels_fieldsplit_0_pc_type sor -stokes_mg_levels_fieldsplit_1_pc_type sor -stokes_mg_levels_ksp_type chebyshev -stokes_mg_levels_ksp_max_it 1 -stokes_mg_levels_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_pc_mg_levels 4 -stokes_ksp_view -log_summary -options_left' >> petsc_ex43_pipegcr_test1.batch
sbatch petsc_ex43_pipegcr_test1.batch
rm petsc_ex43_pipegcr_test1.batch
fi;

# Second PIPEGCR test 
if [ $PGCR2 == true ]; then
rm -f petsc_ex43_pipegcr_test2.batch
echo '--Running KSP Tutorial 43 pipelined with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test2.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test2.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_pipegcr_test2.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_pipegcr_test2.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_pipegcr_test2-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test2.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 \
-stokes_ksp_type pipegcr -stokes_ksp_pipegcr_mmax '$OLDDIRS' -stokes_ksp_rtol 1e-8  -stokes_ksp_converged_reason -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type cg -stokes_fieldsplit_0_ksp_rtol 1e-5 -stokes_fieldsplit_0_pc_type ksp -stokes_fieldsplit_0_ksp_ksp_type preonly -stokes_fieldsplit_0_ksp_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly -stokes_fieldsplit_1_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -log_summary -options_left' >> petsc_ex43_pipegcr_test2.batch
sbatch petsc_ex43_pipegcr_test2.batch
rm petsc_ex43_pipegcr_test2.batch
fi;
#-stokes_ksp_type pipegcr -stokes_ksp_norm_type natural -stokes_ksp_pipegcr_mmax '$OLDDIRS' -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type preonly -stokes_fieldsplit_0_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly -stokes_fieldsplit_1_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -log_summary -options_left' >> petsc_ex43_pipegcr_test2.batch

# Third PIPEGCR test 
if [ $PGCR3 == true ]; then
rm -f petsc_ex43_pipegcr_test3.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test3.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test3.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_pipegcr_test3.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_pipegcr_test3.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_pipegcr_test3-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test3.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43 -stokes_ksp_type pipegcr -stokes_ksp_pipegcr_mmax '$OLDDIRS' -stokes_ksp_rtol 1e-8 -stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE -stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2 -stokes_fieldsplit_0_ksp_type preonly -stokes_fieldsplit_0_pc_type ksp -stokes_fieldsplit_0_ksp_ksp_type chebyshev -stokes_fieldsplit_0_ksp_pc_type bjacobi -stokes_fieldsplit_1_ksp_type preonly  -stokes_fieldsplit_1_pc_type ksp -stokes_fieldsplit_1_ksp_ksp_type chebyshev -stokes_fieldsplit_1_ksp_pc_type bjacobi -c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2 -mx '$MX' -my '$MY' -stokes_ksp_monitor_short -stokes_fieldsplit_0_ksp_ksp_monitor_short -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_pipegcr_test3.batch
sbatch petsc_ex43_pipegcr_test3.batch
rm petsc_ex43_pipegcr_test3.batch
fi;

# 4th PIPEGCR test using settings suggested by Dave
if [ $PGCR4 == true ]; then
rm -f petsc_ex43_pipegcr_test4.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test4.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test4.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_pipegcr_test4.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_pipegcr_test4.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_pipegcr_test4-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test4.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-stokes_ksp_type gcr  -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8  -stokes_ksp_converged_reason		\
-stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE	\
-stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2							\
-stokes_fieldsplit_0_ksp_type pipegcr											\
-stokes_fieldsplit_0_ksp_pipegcr_mmax '$OLDDIRS'									\
-stokes_fieldsplit_0_ksp_max_it 300											\
-stokes_fieldsplit_0_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_0_ksp_monitor_short											\
-stokes_fieldsplit_0_pc_type asm											\
-stokes_fieldsplit_0_pc_asm_overlap 4											\
-stokes_fieldsplit_1_ksp_type pipegcr											\
-stokes_fieldsplit_1_ksp_pipegcr_mmax '$OLDDIRS'									\
-stokes_fieldsplit_1_ksp_max_it 300											\
-stokes_fieldsplit_1_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_1_ksp_monitor_short											\
-stokes_fieldsplit_1_pc_type asm											\
-stokes_fieldsplit_1_pc_asm_overlap 4											\
-c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2							\
-mx '$MX' -my '$MY'													\
-stokes_ksp_monitor_short  -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_pipegcr_test4.batch
sbatch petsc_ex43_pipegcr_test4.batch
rm petsc_ex43_pipegcr_test4.batch
fi;

# 5th PIPEGCR test using settings suggested by Dave
if [ $PGCR5 == true ]; then
rm -f petsc_ex43_pipegcr_test5.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test5.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test5.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_pipegcr_test5.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_pipegcr_test5.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_pipegcr_test5-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test5.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8  -stokes_ksp_converged_reason		\
-stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE	\
-stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2							\
-stokes_fieldsplit_0_ksp_type pipegcr											\
-stokes_fieldsplit_0_ksp_pipegcr_mmax '$OLDDIRS'									\
-stokes_fieldsplit_0_ksp_max_it 300											\
-stokes_fieldsplit_0_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_0_ksp_monitor_short											\
-stokes_fieldsplit_0_pc_type asm											\
-stokes_fieldsplit_0_pc_asm_overlap 4											\
-stokes_fieldsplit_0_sub_pc_factor_fill 4										\
-stokes_fieldsplit_1_ksp_type pipegcr											\
-stokes_fieldsplit_1_ksp_pipegcr_mmax '$OLDDIRS'									\
-stokes_fieldsplit_1_ksp_max_it 300											\
-stokes_fieldsplit_1_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_1_ksp_monitor_short											\
-stokes_fieldsplit_1_pc_type asm											\
-stokes_fieldsplit_1_pc_asm_overlap 4											\
-stokes_fieldsplit_1_sub_pc_factor_fill 4										\
-c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2							\
-mx '$MX' -my '$MY'													\
-stokes_ksp_monitor_short  -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_pipegcr_test5.batch
sbatch petsc_ex43_pipegcr_test5.batch
rm petsc_ex43_pipegcr_test5.batch
fi;

# 6th PIPEGCR test using settings suggested by Dave using lu as PC
if [ $PGCR6 == true ]; then
rm -f petsc_ex43_pipegcr_test6.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test6.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test6.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_pipegcr_test6.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_pipegcr_test6.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_pipegcr_test6-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test6.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-stokes_ksp_type gcr -stokes_ksp_gcr_restart '$OLDDIRS' -stokes_ksp_rtol 1e-8 -stokes_ksp_converged_reason		\
-stokes_pc_type fieldsplit -stokes_pc_fieldsplit_block_size 3 -stokes_pc_fieldsplit_type SYMMETRIC_MULTIPLICATIVE	\
-stokes_pc_fieldsplit_0_fields 0,1 -stokes_pc_fieldsplit_1_fields 2							\
-stokes_fieldsplit_0_ksp_type pipegcr											\
-stokes_fieldsplit_0_ksp_pipegcr_mmax '$OLDDIRS'									\
-stokes_fieldsplit_0_ksp_max_it 300											\
-stokes_fieldsplit_0_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_0_ksp_monitor_short											\
-stokes_fieldsplit_0_pc_type asm											\
-stokes_fieldsplit_0_pc_asm_overlap 4											\
-stokes_fieldsplit_0_sub_pc_type lu											\
-stokes_fieldsplit_1_ksp_type pipegcr											\
-stokes_fieldsplit_1_ksp_pipegcr_mmax '$OLDDIRS'									\
-stokes_fieldsplit_1_ksp_max_it 300											\
-stokes_fieldsplit_1_ksp_rtol 1.0e-5											\
-stokes_fieldsplit_1_ksp_monitor_short											\
-stokes_fieldsplit_1_pc_type asm											\
-stokes_fieldsplit_1_pc_asm_overlap 4											\
-stokes_fieldsplit_1_sub_pc_type lu											\
-c_str 0 -solcx_eta0 1.0 -solcx_eta1 1.0e6 -solcx_xc 0.5 -solcx_nz 2							\
-mx '$MX' -my '$MY'													\
-stokes_ksp_monitor_short  -log_summary -options_left -stokes_ksp_view' >> petsc_ex43_pipegcr_test6.batch
sbatch petsc_ex43_pipegcr_test6.batch
rm petsc_ex43_pipegcr_test6.batch
fi;

# 7th PIPEGCR test using settings suggested by Patrick
if [ $PGCR7 == true ]; then
rm -f petsc_ex43_pipegcr_test7.batch
echo '--Running KSP Tutorial 43 with '$TASKS' MPI process' 
echo '#!/bin/bash' > petsc_ex43_pipegcr_test7.batch
echo '#SBATCH --ntasks='$TASKS >> petsc_ex43_pipegcr_test7.batch
echo '#SBATCH --time='$TIME >> petsc_ex43_pipegcr_test7.batch
if [ $MACHINENAME == daint ]; then echo '#SBATCH --account=c05'   >> petsc_ex43_pipegcr_test7.batch; fi;
echo '#SBATCH --output=out/petsc_ex43_pipegcr_test7-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out' >> petsc_ex43_pipegcr_test7.batch
echo 'aprun -n'$TASKS' -j'$CPUS' -d'$THREADS' ./src/ksp/ksp/examples/tutorials/ex43					\
-options_left 1 \
-stokes_ksp_monitor \
-stokes_ksp_view \
-stokes_ksp_converged_reason \
-sinker_eta0 1.0e-2 -sinker_eta1 1.0e2 \
-stokes_ksp_type pipegcr \
-stokes_ksp_rtol 1e-06 \
-stokes_ksp_max_it 399 \
-stokes_pc_type fieldsplit \
-stokes_pc_use_amat \
-stokes_pc_fieldsplit_type schur \
-stokes_pc_fieldsplit_schur_fact_type upper \
-stokes_fieldsplit_p_ksp_type preonly \
-stokes_fieldsplit_p_pc_type bjacobi \
-stokes_fieldsplit_u_ksp_monitor \
-stokes_fieldsplit_u_ksp_rtol 1e-1 \
-stokes_fieldsplit_u_pc_type mg \
-stokes_fieldsplit_u_pc_mg_log \
-stokes_fieldsplit_u_mg_coarse_pc_type lu \
-stokes_fieldsplit_u_mg_coarse_pc_factor_mat_solver_package mumps \
-stokes_fieldsplit_u_pc_mg_galerkin \
-stokes_fieldsplit_u_pc_mg_levels 4 \
-stokes_fieldsplit_u_mg_levels_3_pc_type asm \
-stokes_fieldsplit_u_mg_levels_3_ksp_type fgmres \
-stokes_fieldsplit_u_mg_levels_3_ksp_max_it 1 \
-stokes_fieldsplit_u_mg_levels_3_pc_asm_type restrict \
-stokes_fieldsplit_u_mg_levels_3_sub_pc_type  ilu \
-stokes_fieldsplit_u_mg_levels_3_pc_asm_dm_subdomains 1 \
-stokes_fieldsplit_u_mg_levels_3_pc_asm_overlap 4 \
-stokes_fieldsplit_u_mg_levels_1_ksp_type chebyshev -stokes_fieldsplit_u_mg_levels_1_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_fieldsplit_u_mg_levels_1_est_ksp_norm_type none \
-stokes_fieldsplit_u_mg_levels_1_est_ksp_max_it 6 \
-stokes_fieldsplit_u_mg_levels_1_fieldsplit_0_ksp_max_it 15 \
-stokes_fieldsplit_u_mg_levels_1_fieldsplit_0_pc_type jacobi -stokes_fieldsplit_u_mg_levels_1_fieldsplit_0_ksp_norm_type none \
-stokes_fieldsplit_u_mg_levels_2_ksp_type chebyshev -stokes_fieldsplit_u_mg_levels_2_ksp_chebyshev_estimate_eigenvalues 0,0.2,0,1.1 -stokes_fieldsplit_u_mg_levels_2_est_ksp_norm_type none \
-stokes_fieldsplit_u_mg_levels_2_est_ksp_max_it 6 \
-stokes_fieldsplit_u_mg_levels_2_fieldsplit_0_ksp_max_it 15 \
-stokes_fieldsplit_u_mg_levels_2_fieldsplit_0_pc_type jacobi -stokes_fieldsplit_u_mg_levels_2_fieldsplit_0_ksp_norm_type none \
-da_refine_x 4 -da_refine_y 4 \
-c_str 2 \
-mx '$MX' -my '$MY >> petsc_ex43_pipegcr_test7.batch
sbatch petsc_ex43_pipegcr_test7.batch
rm petsc_ex43_pipegcr_test7.batch
fi;

# ===================================================================================================
# END OF TEST DEFINITIONS
# ===================================================================================================

echo "--Removing example binaries"
rm -f src/examples/tutorials/ex43
#rm -f src/examples/tutorials/ex49

echo ''
echo "${redColor}Once the jobs are finished, check the output with${noColor}"
if [ $GCR1 == true ]; then echo '  cat out/petsc_ex43_gcr_test1-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $GCR2 == true ]; then echo '  cat out/petsc_ex43_gcr_test2-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $GCR3 == true ]; then echo '  cat out/petsc_ex43_gcr_test3-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $GCR4 == true ]; then echo '  cat out/petsc_ex43_gcr_test4-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $GCR5 == true ]; then echo '  cat out/petsc_ex43_gcr_test5-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $GCR6 == true ]; then echo '  cat out/petsc_ex43_gcr_test6-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $GCR7 == true ]; then echo '  cat out/petsc_ex43_gcr_test7-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $PGCR1 == true ]; then echo '  cat out/petsc_ex43_pipegcr_test1-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $PGCR2 == true ]; then echo '  cat out/petsc_ex43_pipegcr_test2-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $PGCR3 == true ]; then echo '  cat out/petsc_ex43_pipegcr_test3-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $PGCR4 == true ]; then echo '  cat out/petsc_ex43_pipegcr_test4-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $PGCR5 == true ]; then echo '  cat out/petsc_ex43_pipegcr_test5-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $PGCR6 == true ]; then echo '  cat out/petsc_ex43_pipegcr_test6-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
if [ $PGCR7 == true ]; then echo '  cat out/petsc_ex43_pipegcr_test7-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'; fi;
#echo '  cat out/petsc_ex49_gcr_test1-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
#echo '  cat out/petsc_ex49_gcr_test2-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
#echo '  cat out/petsc_ex49_pipegcr_test1-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'
#echo '  cat out/petsc_ex49_pipegcr_test2-'$MACHINENAME'-n'$TASKS'-j'$CPUS'-d'$THREADS'-mx'$MX'-my'$MY'.out'

GREPSCRIPT='out/grep_petsc_ex43_gcr_'$MACHINENAME'-n'$TASKS'-mx'$MX'-my'$MY'.sh'
echo "redColor='\033[0;31m'"										>  $GREPSCRIPT
echo "noColor='\033[0m'"										>> $GREPSCRIPT
echo 'alias echo="echo -e"'										>> $GREPSCRIPT
echo 'echo "${redColor}-- CHECKING FOR WARNINGS AND ERRORS${noColor}"'					>> $GREPSCRIPT
echo 'grep -i -A1 "warning\|error"	out/*gcr*'$MACHINENAME'*'$TASKS'*'$MX'*'$MY'.out'		>> $GREPSCRIPT
echo 'echo ""'												>> $GREPSCRIPT
echo 'echo "${redColor}-- TOTAL TIME FOR SOLVE${noColor}"'						>> $GREPSCRIPT
echo 'grep -A6 "Time (sec):"			out/*gcr*'$MACHINENAME'*'$TASKS'*'$MX'*'$MY'.out'	>> $GREPSCRIPT
echo 'echo ""'												>> $GREPSCRIPT
echo 'echo "${redColor}-- KSPSolve LOG${noColor}"'							>> $GREPSCRIPT
echo 'grep "KSPSolve"				out/*gcr*'$MACHINENAME'*'$TASKS'*'$MX'*'$MY'.out'	>> $GREPSCRIPT
echo 'echo ""'												>> $GREPSCRIPT
echo 'echo "${redColor}-- UNUSED OPTIONS (At most one unused option is shown by grep)${noColor}"'	>> $GREPSCRIPT
echo 'grep -i -A2 "unused[A-Za-z ]*option."	out/*gcr*'$MACHINENAME'*'$TASKS'*'$MX'*'$MY'.out'	>> $GREPSCRIPT
echo 'echo ""'												>> $GREPSCRIPT
echo 'echo "${redColor}-- CONVERGED_REASON${noColor}"'							>> $GREPSCRIPT
echo 'grep "[CONDI]*VERGED"			out/*gcr*'$MACHINENAME'*'$TASKS'*'$MX'*'$MY'.out'	>> $GREPSCRIPT
echo 'echo ""'												>> $GREPSCRIPT
echo ''
echo "${redColor}Run grep script for viewing timings, potential unused options and converged_reason using${noColor}"
echo '  . '$GREPSCRIPT
echo ''
