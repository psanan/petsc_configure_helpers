#!/usr/bin/env python
import os
# make sure to load the correct modules 
#  module unload PrgEnv-cray && module load PrgEnv-gnu && module load cudatoolkit
#

# Get CUDATOOLKIT_HOME from environment
CUDATOOLKIT_HOME=os.getenv('CUDATOOLKIT_HOME')
if not CUDATOOLKIT_HOME :
  raise Exception("CUDATOOLKIT_HOME not defined in the environment. Did you forget to load modules?")

configure_options = [
# On cray cc,CC,ftn are eqivalent to mpicc,mpiCC,mpif90
# Note that we add some flags, OVERRIDING any existing COPTFLAGS ans CXXOPTFLAGS..
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=0',

  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',
  '--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=1',
  '--with-valgrind=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-x=0',
  #'--with-hwloc=0'

  'PETSC_ARCH=arch-gnu-xc30-daint-debug',
  #'--with-blas-lapack-lib=-L/opt/cray...'

  '--with-opencl',
  '--with-opencl-lib='+CUDATOOLKIT_HOME+'/lib64/libOpenCL.so',
  '--with-opencl-include='+CUDATOOLKIT_HOME+'/include',

  #'--download-viennacl',

  '--with-viennacl=1',
  '--with-viennacl-include=../viennacl-dev',
  '--with-viennacl-lib= ',

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
