# A convenience script to run the C/C++ tests for this particular architecture. 
# Note that PETSC_ARCH is hardcoded below
# The settings have been copied from the runex19 settings at the time of this writing
#
# Note that the jobs are launched with a maximum time of 3 seconds, and the script waits that long for the output. This doesn't work very well.
# A better solution is to just make this script run the batch for you, and let you parse the output. TODO

# Build the example binary
echo "--Building example"
make -C src/snes/examples/tutorials PETSC_DIR=../../../.. PETSC_ARCH=arch-gnu-xc30-daint clean
make -C src/snes/examples/tutorials PETSC_DIR=../../../.. PETSC_ARCH=arch-gnu-xc30-daint ex19

# First test - single process
rm -f arch-gnu-xc30-daint-test1.out petsc_ex19_test1.batch
echo '--Running SNES Tutorial on with 1 MPI process' 
echo '#!/bin/bash' > petsc_ex19_test1.batch
echo '#SBATCH --ntasks=1' >> petsc_ex19_test1.batch
echo '#SBATCH --time=00:00:03' >> petsc_ex19_test1.batch
echo '#SBATCH --output=arch-gnu-xc30-daint-test1.out' >> petsc_ex19_test1.batch
echo 'aprun -n 1 ./src/snes/examples/tutorials/ex19 -da_refine 3 -snes_monitor_short -pc_type mg -ksp_type fgmres -pc_mg_type full' >> petsc_ex19_test1.batch
sbatch petsc_ex19_test1.batch
rm petsc_ex19_test1.batch


 # Second test - 2 multithreaded processes on 2 nodes
 rm -f arch-gnu-xc30-daint-test2.out petsc_ex19_test2.batch
 echo '--Running SNES Tutorial on with 2 MPI processes (on one node)' 
 echo '#!/bin/bash' > petsc_ex19_test2.batch
 echo '#SBATCH --ntasks=2' >> petsc_ex19_test2.batch
 echo '#SBATCH --time=00:00:03' >> petsc_ex19_test2.batch
 echo '#SBATCH --output=arch-gnu-xc30-daint-test2.out' >> petsc_ex19_test2.batch
 echo 'aprun -n 2 ./src/snes/examples/tutorials/ex19 -da_refine 3 -snes_monitor_short -pc_type mg -ksp_type fgmres -pc_mg_type full' >> petsc_ex19_test2.batch
 sbatch petsc_ex19_test2.batch
 rm -f petsc_ex19_test2.batch

echo "--Removing example binary"
rm -f src/examples/tutorials/ex19

echo ""
echo "Once the jobs are finished, check the output with"
echo "  cat arch-gnu-xc30-daint-test1.out"
echo "  cat arch-gnu-xc30-daint-test2.out"
