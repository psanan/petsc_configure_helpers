PETSc Configure Helpers
=======================

Scripts to help with `PETSc <https://www.mcs.anl.gov/petsc>`__ configuration.

Local
~~~~~

``petsc_configure.py`` provides a thin wrapper around PETSc's configure script.
Example usage:

::

    git clone https://github.com/psanan/petsc_configure_helpers
    git clone https://gitlab.com/petsc/petsc -b maint petsc-maint
    cd petsc-maint
    ../petsc_configure_helpers/petsc_configure.py --archmod=maint --extra=2 --with-debugging=0

Clusters
~~~~~~~~

See ``arch-xxx.py``. Example usage:

::

    module load PrgEnv-cray
    cd $HOME
    git clone https://bitbucket.org/petsc/petsc -b maint petsc-maint
    cd petsc-maint
    unset PETSC_DIR PETSC_ARCH
    python $HOME/petsc_configure_helpers/arch-cray-xc50-daint.py
    make
    git submodule init && git submodule update --recursive
    $HOME/petsc_configure_helpers/test.py    # wait for jobs to finish
    $HOME/petsc_configure_helpers/test.py -v
    $HOME/petsc_configure_helpers/test.py -p
