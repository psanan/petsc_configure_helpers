#!/usr/bin/env python
# Piz Daint. requires:
#  module unload PrgEnv-cray && module load PrgEnv-gnu cray-trilinos cray-netcdf-hdf5parallel cray-hdf5-parallel

# Note: these settings were chosen to work with SALVUS

import os

CRAY_TRILINOS_PREFIX_DIR=os.getenv('CRAY_TRILINOS_PREFIX_DIR')
if not CRAY_TRILINOS_PREFIX_DIR :
  raise Exception('CRAY_TRILINOS_PREFIX_DIR not found in environment. You probably forgot to load the correct modules.')
NETCDF_DIR=os.getenv('NETCDF_DIR')
if not NETCDF_DIR :
  raise Exception('NETCDF_DIR not found in environment. You probably forgot to load the correct modules.')
HDF5_ROOT=os.getenv('HDF5_ROOT')
if not HDF5_ROOT :
  raise Exception('HDF5_ROOT not found in environment. You probably forgot to load the correct modules.')

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
  '--download-chaco',
  '--download-metis',
  '--download-parmetis',
  '--with-hdf5',
  '--with-hdf5-dir='+HDF5_ROOT,
  '--with-netcdf',
  '--with-netcdf-dir='+NETCDF_DIR,
  '--with-exodusii',
  '--with-exodusii-dir='+CRAY_TRILINOS_PREFIX_DIR,
  '--with-precision=double',
  'PETSC_ARCH=arch-gnu-xc50-daint-double-extra'
  ]

if __name__ == '__main__':
  import sys,os
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
