#!/usr/bin/env python
modules = " module purge && module load gcc/6.3.0 openmpi/2.1.0 hdf5/1.10.1 openblas/0.2.19 libpng/1.6.27 python_cpu/3.6.4 "
import os
import sys

if 'HDF5_ROOT' in os.environ:
  HDF5_ROOT = os.environ['HDF5_ROOT']
else:
  print("HDF_ROOT not found in environment. Did you load the correct modules?")
  print(modules)
  sys.exit(1)

configure_options = [
     '--with-fc=mpif90',
     '--with-cc=mpicc ',
     '--with-cxx=mpiCC',
     '--with-valgrind=0',
     '--download-metis',
     '--download-parmetis', 
     '--download-scalapack',
     '--download-mumps',
     '--download-suitesparse',
     '--with-debugging=no',
     '--FOPTFLAGS=\'-g -O3\'', 
     '--COPTFLAGS=\'-g -O3\'' ,
     '--CXXOPTFLAGS=\'-g -O3\'',
     '--known-mpi-shared-libraries=1 ',
     '--with-blas-lapack-lib=-lopenblas',
     '--with-shared-libraries=0',
     '--with-hdf5',
     '--with-hdf5-dir=' + HDF5_ROOT,
     'PETSC_ARCH=arch-leonhard',
]

if __name__ == '__main__':
  sys.path.insert(0,os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
