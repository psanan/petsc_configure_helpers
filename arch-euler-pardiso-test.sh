# This expects to run from PETSC_DIR
#
# Note that PETSC_ARCH is hardcoded below
#
# The settings have been copied from the runex19 settings at the time of this writing
#

echo "--Building example"
make -C src/snes/examples/tutorials PETSC_DIR=../../../.. PETSC_ARCH=arch-euler-pardiso clean
make -C src/snes/examples/tutorials PETSC_DIR=../../../.. PETSC_ARCH=arch-euler-pardiso ex19

rm -f arch-euler-pardiso-test1.out
bsub -o arch-euler-pardiso-test1.out ./src/snes/examples/tutorials/ex19 -da_refine 3 -snes_monitor_short -pc_type mg -ksp_type fgmres -pc_mg_type full

rm -f arch-euler-pardiso-test2.out
bsub -n 2 -o arch-euler-pardiso-test2.out mpirun ./src/snes/examples/tutorials/ex19 -da_refine 3 -snes_monitor_short -pc_type mg -ksp_type fgmres -pc_mg_type full

echo ""
echo "Expected Output is approximately"
echo " ------------------------------ "
echo " lid velocity = 0.0016, prandtl # = 1., grashof # = 1."
echo "  0 SNES Function norm 0.0406612"
echo "  1 SNES Function norm 3.33636e-06"
echo "  2 SNES Function norm 1.653e-11"
echo "Number of SNES iterations = 2"
echo " ------------------------------ "
echo ""
echo "Once the jobs are finished, check the output with"
echo "  cat arch-euler-pardiso-test1.out"
echo "  cat arch-euler-pardiso-test2.out"
