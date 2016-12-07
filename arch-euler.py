#!/usr/bin/env python
#
# PETSc configure script for Euler
# 
# Sample Build Instructions:
# 1. Get the PETSc "maint" (the latest release) source.
#
#    git clone git@bitbucket.org:petsc/petsc -b maint
#
# 2. Load required modules (assuming you want GCC compilers and OpenMPI). The order matters.
#
#    module load python/2.7.6
#    module load openblas
#    module load gcc
#    module load open_mpi
#
# 3. Configure PETSc
#
#    # copy arch-euler.py (this file) to the current directory (the PETSC_DIR)
#    ./arch-euler.py
#
# 4. Submit conftest.
#
#    bsub ./conftest-arch-euler
#    bjobs # see if your job is still queued
#
# 5. Continue configuration.
#
#    ./reconfigure-arch-euler.py
#
# 6. Build the library. (Use the command below or copy the suggested one)
#
#    make PETSC_DIR=$PWD PETSC_ARCH=arch-euler all
#
# 7. Test.
#
#    # move arch-euler-test.sh to the current directory (the PETSC_DIR)
#    ./arch-euler-test.sh
#
# 8. Use PETSc.
#
#   export PETSC_DIR=$PWD
#   export PETSC_ARCH=arch-euler
#
# Last updated 2016.10.5 by Patrick Sanan (patrick.sanan@erdw.ethz.ch)
#

configure_options = [
  #'--with-cc=mpicc',
  #'--with-cxx=mpiCC',
  #'--with-fc=mpif90',

  '--COPTFLAGS=-O3 -march=native',
  '--CXXOPTFLAGS=-O3 -march=native',
  '--FOPTFLAGS=-O3 -march=native',

  #'--with-clib-autodetect=0',
  #'--with-cxxlib-autodetect=0',
  #'--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',
  '--with-x=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-blas-lapack-lib=-lopenblas',

  '--download-suitesparse',

  'PETSC_ARCH=arch-euler',

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
