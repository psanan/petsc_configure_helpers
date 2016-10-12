This repository stores PETSc configure and test scripts for various clusters. 

To get PETSc running on Piz Daint

1) Load up the modules you want. For cray, it might be okay to use the defaults (PrgEnv-cray and cray-mpich). You may also want cudatoolkit or cmake.

2) Configure and build PETSc. For example (with gnu, for cray or a different arch, use the correspondingly-named files)
    git clone https://bitbucket.org/petsc/petsc
    cd petsc
    export PETSC_DIR=xxxxxxxxx
    export PETS_ARCH=xxxxxxxxx
    python ../CSCS_petsc_helpers/arch-gnu-xc30-daint.py
    make PETSC_ARCH=arch-gnu-xc30-daint PETSC_DIR=$PWD
    . ../CSCS_petsc_helpers/arch-gnu-xc30-daint-test.sh