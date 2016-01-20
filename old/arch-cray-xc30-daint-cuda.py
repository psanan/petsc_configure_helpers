#!/usr/bin/env python

import os

# Do the following before running this configure script [daint.cscs.ch]
#
# Module load PrgEnv-cray
# module load cudatoolkit

CUDATOOLKIT_HOME = os.environ['CUDATOOLKIT_HOME']

configure_options = [
  # On cray cc,CC,ftn are equivalent to mpicc,mpiCC,mpif90
  '--with-cc=cc',
  '--with-cxx=CC',

  # We ignore fortran
  '--with-fc=0',

  #'--with-64-bit-indices',

  # This is required to build a static library which can perform asynchronous reductions
  #  see man mpi for more (on how this works with cray-mpich)
  #  In particular, note the required environment variables required when running the job
  #'--CFLAGS=-Wl,--whole-archive,-ldmapp,--no-whole-archive',
  #'--CXXFLAGS=-Wl,--whole-archive,-ldmapp,--no-whole-archive',

  # We clear the optimization flags, since the cray compilers turn on most optimizations by default
  'COPTFLAGS=-O3',
  'CXXOPTFLAGS=-O3',

  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-x=0',

  '--with-cuda=1',
  '--with-cuda-dir='+CUDATOOLKIT_HOME,
  '--with-cuda-arch=sm_35',
  '--with-cudac=nvcc',
  #'--with-thrust=1',
  #'--with-cusp=1'

  '--with-viennacl=1',
  '--with-viennacl-include=../viennacl-dev',
  '--with-viennacl-lib='

  'PETSC_ARCH=arch-cray-xc30-daint-cuda'

  ]

print('Dg' + str(configure_options))

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
