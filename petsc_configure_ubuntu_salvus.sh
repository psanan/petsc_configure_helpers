#!/usr/bin/env bash
# example usage ARCHMOD=maint PRECISION=single DEBUG=0 ../petsc_configure_helpers/petsc_configure_ubuntu_salvus.h
# Note that this is a prefix install.
ARCHNAME=ubuntu

SRCDIR=$(dirname "$0")
MYFC=0
MYCC=mpicc
MYCXX=mpicxx
DOWNLOAD_BLASLAPACK=0
DOWNLOAD_MPICH=0
EXTRAFLAGS=" --download-exodusii \
             --with-blas-lib=/usr/lib/libblas.a --with-lapack-lib=/usr/lib/liblapack.a \
             --download-chaco \
             --with-hdf5 --with-hdf5-dir=/usr/lib/x86_64-linux-gnu/hdf5/mpich \
             --with-netcdf \
             --prefix=/opt/petsc/arch-ubuntu-maint-salvus-$PRECISION-opt \
              "
ARCHMOD+=-salvus

source $SRCDIR/petsc_configure_common.sh
