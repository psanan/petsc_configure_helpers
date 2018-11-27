# PETSc Configure Helpers
Convenience scripts to help with PETSc configuration.

### Local ###
See `petsc_configure.py`. Example usage (untested):

    git clone https://bitbucket.org/psanan/petsc_configure_helpers
    git clone https://bitbucket.org/petsc/petsc -b maint petsc-maint
    cd petsc-maint
    export PDS_PETSC_ARCHNAME=ubuntu # can put in login file
    ../petsc_configure_helpers/petsc_configure.py --archmod=maint --extra=2 --with-debugging=0

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
