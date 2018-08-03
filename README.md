# PETSc Configure Helpers
Convenience scripts to help with PETSc configuration.

### Local ###
See `petsc_configure.sh`. Example usage (untested):

    git clone https://bitbucket.org/petsc/petsc -b maint petsc-maint
    cd petsc-maint
    export PDS_PETSC_ARCHNAME=ubuntu                   # can put in login file
    ARCHMOD=maint DEBUG=0 EXTRA=1 ~/petsc_configure_helpers/petsc_configure.sh

### Clusters ###
See `arch-xxx.py`. Example usage (untested) :

    module load PrgEnv-cray
    git clone https://bitbucket.org/petsc/petsc -b maint petsc-maint
    cd petsc-maint
    unset PETSC_DIR
    unset PETSC_ARCH
    python ~/petsc_configure_helpers/arch-cray-xc50-daint.py
    make
    git clone https://bitbucket.org/dmay/pythontestharness
    ~/petsc_configure_helpers/test.py    # wait for jobs to finish
    ~/petsc_configure_helpers/test.py -v
    ~/petsc_configure_helpers/test.py -p

### KNL
For future use, Satish mentioned something like this on the PETSc mailing list (and see `arch-linux-knl.py` in latest PETSc)

    COPTFLAGS="-g -O3 -fp-model fast -xMIC-AVX512" CXXOPTFLAGS="-g -O3 -fp-model fast -xMIC-AVX512" FOPTFLAGS="-g -O3 -fp-model fast -xMIC-AVX512
