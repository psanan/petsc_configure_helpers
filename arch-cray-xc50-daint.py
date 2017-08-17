#!/usr/bin/env python
# Piz Daint. requires:
#  module load PrgEnv-cray

configure_options = [
  '--with-cc=cc',
  '--with-cxx=CC',
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
  '--download-suitesparse',
  'PETSC_ARCH=arch-cray-xc50-daint'
  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
