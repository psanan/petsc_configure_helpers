#!/usr/bin/env python
#
#    module load python/2.7.6
#    module unload openblas
#    module load intel
#    module load open_mpi
import sys,os

MKLROOT=os.getenv('MKLROOT')

configure_options = [
  '--with-cc=mpicc',
  '--with-cxx=mpiCC',
  '--with-fc=0',

  '--COPTFLAGS=-O3 -march=native -openmp',
  '--CXXOPTFLAGS=-O3 -march=native -openmp',
  #'--FOPTFLAGS=-O3 -march=native',

  #'--with-clib-autodetect=0',
  #'--with-cxxlib-autodetect=0',
  #'--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',
  '--with-x=0',
  '--with-sowing=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-blas-lapack-dir=' + MKLROOT,
  '--with-pardiso=1',
  '--with-pardiso-lib=/cluster/home/pasanan/libpardiso500-GNU481-X86-64.so'
  '--with-openmp',

  'PETSC_ARCH=arch-euler-pardiso',

  ]

if __name__ == '__main__':
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
