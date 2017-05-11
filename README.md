This repository stores some convenience scripts to help with PETSc configuration.

It is NOT very well-maintained at the moment.

### Local ###
See `petsc_configure_xxx.sh`. Usage is something like this (but this hasn't been tested):

    git clone https://bitbucket.org/petsc/petsc -b maint petsc-maint
    ARCHMOD=maint DEBUG=0 EXTRA=1 ~/petsc_configure_helpers/petsc_configure_osx.sh

### Clusters ###
See `arch-xxx.py`. Usage is something like this (but this hasn't been tested):

    module unload PrgEnv-cray
    module load PrgEnv-gnu
    git clone https://bitbucket.org/petsc/petsc -b maint petsc-maint
    cd petsc
    unset PETSC_DIR
    unset PETSC_ARCH
    python ~/petsc_configure_helpers/arch-gnu-xc30-daint.py
    make
    . ~/petsc_configure_helpers/arch-gnu-xc30-daint-test.sh