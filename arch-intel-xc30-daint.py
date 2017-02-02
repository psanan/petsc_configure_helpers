#!/usr/bin/env python

# !!!!!!!!!!!!!! NEEDS TO BE UPDATED !!!!!!!!!!!!

# Do the following before running this configure script [daint.cscs.ch]
#
#   module unload PrgEnv-cray
#   module load PrgEnv-intel
#   module load cmake

import os

MKLROOT=os.getenv('MKLROOT')
if not MKLROOT :
  raise Exception("MKLROOT not defined in the environment. Did you forget to load the PrgEnv-intel module?")


configure_options = [
# On cray cc,CC,ftn are equivalent to mpicc,mpiCC,mpif90
  '--with-cc=cc',
  '--with-cxx=0',
  '--with-fc=ftn',

  '--COPTFLAGS=',
  '--CXXOPTFLAGS=',
  '--FOPTFLAGS=',

  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',
  '--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',

  '--known-mpi-shared-libraries=1',

  '--with-x=0',

  # From Intel MKL Link Advisor
  #  -L${MKLROOT}/lib/intel64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread -lm -ldl
  # and note the trailing -mkl which seems to be required to avoid a undefined symbol when linking
  '--with-blas-lapack-lib=[-L'+MKLROOT+'/lib/intel64,-lmkl_intel_lp64,-lmkl_core,-mkl]',
  '--with-mkl_pardiso=1',
  '--with-mkl_pardiso-dir='+MKLROOT,


  'PETSC_ARCH=arch-intel-xc30-daint',

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
