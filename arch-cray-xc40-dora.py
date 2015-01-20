##!/usr/bin/env python
# note: run this with python /path/here/arch-cray-xc40-dora.py

# Do (at least) the following before running this configure script [daint.cscs.ch]
#
# [Module load PrgEnv-cray]
# Module load cray-mpich
# Module load cmake
#
# You should be okay running the cray-loadmodules.sh here
#
# Note that ATTOTW this is no different from the xc30 daint variant (but we want different petsc arches in any case)

configure_options = [
# On cray cc,CC,ftn are equivalent to mpicc,mpiCC,mpif90
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=ftn',

  #?????? -Wl,--whole-archive,-ldmapp,--no-whole-archive ??????
  #?????? -dynamic
  
  #'--CFLAGS=-craympich-mt',
  #'--CXXFLAGS=-craympich-mt',

  '--CFLAGS=-Wl,--whole-archive,-ldmapp,--no-whole-archive -craympich-mt',
  '--CXXFLAGS=-Wl,--whole-archive,-ldmapp,--no-whole-archive -craympich-mt',

  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',
  '--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-x=0',

  'PETSC_ARCH=arch-cray-xc40-dora',
  #'--with-blas-lapack-lib=-L/opt/cray...'

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)