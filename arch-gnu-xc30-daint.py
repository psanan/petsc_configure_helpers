#!/usr/bin/env python

# make sure to load the correct modules (see gnu-loadmodules.sh)

configure_options = [
# On cray cc,CC,ftn are eqivalent to mpicc,mpiCC,mpif90
# Note that we add some flags, OVERRIDING any existing COPTFLAGS ans CXXOPTFLAGS..
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=ftn',

  '--with-clib-autodetect=0',
  '--with-cxxlib-autodetect=0',
  '--with-fortranlib-autodetect=0',

  '--with-shared-libraries=0',
  '--with-debugging=0',
  '--with-valgrind=0',

  '--with-batch',
  '--known-mpi-shared-libraries=1',

  '--with-x=0',

  'PETSC_ARCH=arch-gnu-xc30-daint',
  #'--with-blas-lapack-lib=-L/opt/cray...'

  '--download-viennacl',
  '--with-opencl=yes',
  '--with-opencl-lib=/opt/cray/nvidia/default/lib64/libOpenCL.so',
  '--with-opencl-include=/opt/nvidia/cudatoolkit/5.5.20-1.0501.7945.8.2/include',

  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
