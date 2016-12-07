#!/usr/bin/env python
#

configure_options = [

  '--COPTFLAGS=-O3 -march=native',
  '--CXXOPTFLAGS=-O3 -march=native',
  '--FOPTFLAGS=-O3 -march=native',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',
  '--with-x=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-blas-lapack-lib=-lopenblas',

  '--download-suitesparse',
  '--download-superlu',
  '--download-scalapack',
  '--download-mumps',
  '--download-metis',
  '--download-parmetis',

  'PETSC_ARCH=arch-euler-extra',

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
