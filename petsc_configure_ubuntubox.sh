ARCHNAME=ubuntu

#USE_CUSTOM_OPENCL_DIR=1
#CUSTOM_OPENCL_DIR=/usr/local/cuda-7.0
#EXTRA=1

USE_VIENNACL=${USE_VIENNACL:-0}
USE_SUITESPARSE=${USE_SUITESPARSE:-1}


SRCDIR=$(dirname "$0")
source $SRCDIR/petsc_configure_common.sh
