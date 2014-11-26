To get PETSc running on daint

1) Load up the modules you want. For example
    . gnu-loadmodules.sh

2) Configure and build PETSc. For example
    git clone https://bitbucket.org/petsc/petsc
    cd petsc
    python ../petsc_daint_helpers/arch-gnu-xc30-daint.py
    . ../petsc_daint_helpers/arch-gnu-xc30-daint-conftest-batchsubmit.sh
    ./reconfigure-arch-gnu-xc30-daint.py
    make PETSC_ARCH=arch-gnu-xc30-daint PETSC_DIR=$PWD
    . ../petsc_daint_helpers/arch-gnu-xc30-daint-test.sh

 3) To test GPU subsolves, you can do something like
    [set up a remote, check out psanan/pc-asm-sub-type]
    make
    export PETSC_DIR=$PWD
    export PETSC_ARCH=arch-gnu-xc30-daint
    cd src/ksp/ksp/examples/tutorials
    make ex23
    sbatch ~/petsc_daint_helpers/ex3_twogpus.sbatch
    watch squeue -u psanan
    cat ex23_twogpus.out