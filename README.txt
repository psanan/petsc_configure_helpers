To get PETSc running on daint

1) Load up the modules you want. For cray, it might be okay to use the defaults (PrgEnv-cray and cray-mpich). There is also
    . cray-loadmodules-daint.sh / cray-loadmodules-dora.sh
 For gnu, you can use
    . gnu-loadmodules-daint.sh

2) Configure and build PETSc. For example (with gnu, for cray or a different arch, use the correspondingly-named files)
    git clone https://bitbucket.org/petsc/petsc
    cd petsc
    set PETSC_DIR and PETSC_ARCH
    python ../CSCS_petsc_helpers/arch-gnu-xc30-daint.py
    . ../CSCS_petsc_helpers/arch-gnu-xc30-daint-conftest-batchsubmit.sh
    ./reconfigure-arch-gnu-xc30-daint.py
    make PETSC_ARCH=arch-gnu-xc30-daint PETSC_DIR=$PWD
    . ../CSCS_petsc_helpers/arch-gnu-xc30-daint-test.sh

 3) To test GPU subsolves, you can do something like
    [set up a remote, check out psanan/pc-asm-sub-type]
    make
    export PETSC_DIR=$PWD
    export PETSC_ARCH=arch-gnu-xc30-daint
    cd src/ksp/ksp/examples/tutorials
    make ex23
    sbatch ~/CSCS_petsc_helpers/ex23_twogpus.sbatch
    watch squeue -u psanan
    cat ex23_twogpus.out