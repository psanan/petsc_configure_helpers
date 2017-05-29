This repository stores some convenience scripts to help with PETSc configuration.

It is NOT very well-maintained at the moment.

### Local ###
See `petsc_configure_XXX.sh`. Usage is something like this (but this hasn't been tested):

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

### KNL
For future use, Satish mentioned something like this on the PETSc mailing list

    COPTFLAGS="-g -O3 -fp-model fast -xMIC-AVX512" CXXOPTFLAGS="-g -O3 -fp-model fast -xMIC-AVX512" FOPTFLAGS="-g -O3 -fp-model fast -xMIC-AVX512

