#!/usr/bin/env python

# Make sure to load the correct modules:
#  module unload PrgEnv-cray && module load PrgEnv-gnu

configure_options = [
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=ftn',

  'COPTFLAGS=',
  'CXXOPTFLAGS=',
  'FOPTFLAGS=',

  '--download-suitesparse',
  '--download-yaml',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-x=0',

  'PETSC_ARCH=arch-gnu-xc50-daint',
  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
