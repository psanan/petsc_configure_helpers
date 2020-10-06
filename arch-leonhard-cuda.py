#!/usr/bin/env python
import os
import sys

MODULES = "module purge && module load gcc/6.3.0 openblas openmpi cuda/10.1.243"

if 'CUDA_HOME' in os.environ:
  CUDA_HOME = os.environ['CUDA_HOME']
else:
  print("CUDA_HOME not found in environment. Did you load the correct modules?")
  print("  " + MODULES)
  sys.exit(1)

configure_options = [
     '--with-fc=mpif90',
     '--with-cc=mpicc',
     '--with-cxx=mpiCC',
     '--with-cuda=1',
     '--with-cuda-dir=%s' % CUDA_HOME,
     '--with-valgrind=0',
     '--with-debugging=no',
     '--FOPTFLAGS=\'-g -O3\'',
     '--COPTFLAGS=\'-g -O3\'' ,
     '--CXXOPTFLAGS=\'-g -O3\'',
     '--known-mpi-shared-libraries=1 ',
     '--with-blaslapack-lib=-lopenblas',
     '--with-shared-libraries=0',
     'PETSC_ARCH=arch-leonhard-cuda',
     'LIBS=-lgomp',
]

if __name__ == '__main__':
  sys.path.insert(0, os.path.abspath('config'))
  import configure
  configure.petsc_configure(configure_options)
