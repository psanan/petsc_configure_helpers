#!/usr/bin/env python
import os

MODULES = "module load daint-gpu PrgEnv-cray craype-accel-nvidia60"

if 'CUDATOOLKIT_HOME' in os.environ:
  CUDATOOLKIT_HOME = os.environ['CUDATOOLKIT_HOME']
else:
  print("CUDATOOLKIT_HOME not found in environment. Did you load the correct modules?")
  print("  " + modules)
  sys.exit(1)

configure_options = [
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=ftn',
  '--COPTFLAGS=-g -O3',
  '--CXXOPTFLAGS=-g -O3',
  '--FOPTFLAGS=-g -O3',
  '--CUDAOPTFLAGS=-O3',
  '--with-cuda=1',
  '--with-cuda-dir=%s' % CUDATOOLKIT_HOME,
  '--with-cuda-gencodearch=60',
  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',
  '--with-fortranlib-autodetect=0',
  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',
  '--known-mpi-shared-libraries=1',
  '--with-x=0',
  '--known-64-bit-blas-indices=0',
  '--download-suitesparse',
  'PETSC_ARCH=arch-daint'
  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
