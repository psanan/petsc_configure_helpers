#!/usr/bin/env python

#    module load python/2.7.6
#    module load openblas
#    module load gcc
#    module load open_mpi

import sys,os

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

  '--with-pardiso=1',
  '--with-pardiso-lib=/cluster/home/pasanan/pardiso/libpardiso.so', # must be sym linked to the GNU481 version!!
  '--with-openmp',

  'PETSC_ARCH=arch-euler-pardiso',

  ]

if __name__ == '__main__':
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
