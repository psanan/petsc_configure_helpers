#!/usr/bin/env python

configure_options = [
  '--with-debugging=0',
  '--with-cc=cc',
  '--with-cxx=CC',
  '--with-fc=0',
  '--with-batch=1',
  '--known-64-bit-blas-indices=0',
  '--download-suitesparse',
  '--LDFLAGS=-dynamic',
  'PETSC_ARCH=arch-daint'
  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
