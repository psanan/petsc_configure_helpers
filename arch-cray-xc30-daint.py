#!/usr/bin/env python

# Do the following before running this configure script [daint.cscs.ch]
#
# [Module load PrgEnv-cray]

configure_options = [
# On cray cc,CC,ftn are equivalent to mpicc,mpiCC,mpif90
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=ftn',

  #'--with-64-bit-indices',

  # This is required to build a static library which can perform asynchronous reductions
  #  see man mpi for more (on how this works with cray-mpich)
  #  In particular, note the required environment variables required when running the job
  #'--CFLAGS=-Wl,--whole-archive,-ldmapp,--no-whole-archive',
  #'--CXXFLAGS=-Wl,--whole-archive,-ldmapp,--no-whole-archive',

  # We clear the optimization flags, since the cray compilers turn on most optimizations by default
  '--COPTFLAGS=',
  '--CXXOPTFLAGS=',
  '--FOPTFLAGS=',

  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',
  '--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',

  #'--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-x=0',
  #'--download-scalapack',
  #'--download-mumps',
  #'--download-metis',
  #'--download-parmetis',

  'PETSC_ARCH=arch-cray-xc30-daint'
  #'--with-blas-lapack-lib=-L/opt/cray...'

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
