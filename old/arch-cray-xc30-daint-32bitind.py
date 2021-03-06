#!/usr/bin/env python

# Do the following before running this configure script [daint.cscs.ch]
#
# [Module load PrgEnv-cray]
# Module load cray-mpich
# Module load cmake

configure_options = [
# On cray cc,CC,ftn are equivalent to mpicc,mpiCC,mpif90
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=ftn',

  #'--with-64-bit-indices',

  '--CFLAGS=-craympich-mt',
  '--CXXFLAGS=-craympich-mt',

  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',
  '--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-x=0',
  #'--download-scalapack',
  #'--download-mumps',
  #'--download-metis',
  #'--download-parmetis',

  'PETSC_ARCH=arch-cray-xc30-daint-32bitind'
  #'--with-blas-lapack-lib=-L/opt/cray...'

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
