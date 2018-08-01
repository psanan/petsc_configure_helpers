# Configuration helper for PETSc
# Run this from PETSC_DIR.
#
# For the optimized configuration of the maint branch, use
#
#     DEBUG=0 ARCHMOD=maint /path/to/here/petsc_configure.sh
#
# for a version with debugging and extra packages
#
#     EXTRA=1 ARCHMOD=maint /path/to/here/petsc_configure_common.sh
#
# You can also provide things like PRECISION, SCALARTYPE, etc.
# You can directly pass any other flags you'd like with the CUSTOMS_OPTS variable
#
# I typically do not invoke this script directly,
# but rather use petsc_configure_xxx.sh which sets ARCHNAME
# and any system-specific options.
#
#########################################################################################

# Set the directory to the current directory
PETSC_DIR=$PWD

# We construct our PETSC_ARCH as a root plus some modifiers
PETSC_ARCH_ROOT=arch
PETSC_ARCH=$PETSC_ARCH_ROOT

# Your name for the architecture (say darwin or ubuntu)
ARCHNAME=${ARCHNAME:-unknown}
PETSC_ARCH+=-$ARCHNAME

# Add an arbitrary modifier to the arch
# this is useful if you want an arch that corresponds to a
# specific branch (like maint). We recommend that you always do this.
ARCHMOD=${ARCHMOD:-}
if [ "$ARCHMOD" != "" ]; then
  PETSC_ARCH+=-$ARCHMOD
fi

# Set Precision
PRECISION=${PRECISION:-double}
if [ "$PRECISION" == "double" ]; then
    PETSC_ARCH+=-double
elif [ "$PRECISION" == "single" ]; then
    PETSC_ARCH+=-single
elif [ "$PRECISION" == "__float128" ]; then
    PETSC_ARCH+=-float128
else
  printf "unrecognized precision $PRECISION provided (try python2 ./configure help | grep precision to see available options)\n"
  exit 1
fi

# Set to 0 to skip using viennacl
USE_VIENNACL=${USE_VIENNACL:-0}

# Set to 0 to skip using c2html
USE_C2HTML=${USE_C2HTML:-1}

# Set to 1 to just download SuiteSparse (on by default, since it's handy
#  to have a sparse direct solver available)
USE_SUITESPARSE=${USE_SUITESPARSE:-1}

# Choose download use local (dev) version instead of downloading
# Set to 1 to use ../viennacl-dev
VIENNACL_DEV=${VIENNACL_DEV:-0}

# Set to 1 to add a common set of external packages
# Some are only available for certain values of PRECISION
EXTRA=${EXTRA:-0}
if [ "$EXTRA" == "1" ]; then
  PETSC_ARCH+=-extra
fi

# Set scalar type (real or complex)
SCALARTYPE=${SCALARTYPE:-real}
if [ "$SCALARTYPE" == "real" ]; then
    PETSC_ARCH+=
elif [ "$SCALARTYPE" == "complex" ]; then
    PETSC_ARCH+=-complex
else
  printf "unrecognized scalar type $SCALARTYPE provided\n"
  exit 1
fi

# Set Debug status (1 or 0)
DEBUG=${DEBUG:-1}
if [ "$DEBUG" == "0" ]; then
    PETSC_ARCH+=-opt
else
    PETSC_ARCH+=-debug
    DEBUG=1
fi

# Compilers
MYCC=${MYCC:-gcc}
MYCXX=${MYCXX:-g++}
MYFC=${MYFC:-gfortran}

# BLAS/LAPACK
DOWNLOAD_BLASLAPACK=${DOWNLOAD_BLASLAPACK:-1}

# MPI
DOWNLOAD_MPICH=${DOWNLOAD_MPICH:-1}

#########################################################################################

printf "PETSC_DIR=$PETSC_DIR\n"
printf "PETSC_ARCH=$PETSC_ARCH\n"

# Use PRECISION to choose an appropriate BLAS/LAPACK
if [ "DOWNLOAD_BLASLAPACK" == "1" ]; then
if [ "$PRECISION" == "double" ]; then
    BLAS_LAPACK_OPTS=" --download-fblaslapack "
elif [ "$PRECISION" == "single" ]; then
    BLAS_LAPACK_OPTS=" --download-fblaslapack "
elif [ "$PRECISION" == "__float128" ]; then
    BLAS_LAPACK_OPTS=" --download-f2cblaslapack "
fi
fi

# Note that this is a bit non-intuitive using viennacl-dev, as we specify an empty lib location
if [ "$USE_VIENNACL" == "1" ] && [ "$SCALARTYPE" != "complex" ] ; then
  VIENNACL_OPTS="--with-opencl "
  if [ "$USE_CUSTOM_OPENCL_DIR" == "1" ]]; then
    VIENNACL_OPTS+="--with-opencl-dir=$CUSTOM_OPENCL_DIR "
  fi
  if [ "$VIENNACL_DEV" == "1" ]]; then
    VIENNACL_OPTS+="--with-viennacl=1 --with-viennacl-include=../viennacl-dev --with-viennacl-lib= "
  else
    VIENNACL_OPTS+="--download-viennacl "
  fi
else
  VIENNACL_OPTS=""
fi

if [ "$USE_C2HTML" == "1" ]; then
  C2HTML_OPTS="--download-c2html"
else
  C2HTML_OPTS="-with-c2html=0"
fi

if [ "$USE_SUITESPARSE" == "1" ] && [ "$PRECISION" == "double" ]; then
  SUITESPARSE_OPTS="--download-suitesparse"
else
  SUITESPARSE_OPTS=""
fi

if [ "$EXTRA" == "1" ]; then
  EXTRA_OPTS=" --download-yaml"
  EXTRA_OPTS+=" --download-scalapack --download-metis --download-parmetis --download-mumps"
  EXTRA_OPTS+=" --download-ptscotch --download-pastix"
  if [ "$PRECISION" == "double" ]; then
    EXTRA_OPTS+=" --download-sundials "
    EXTRA_OPTS+=" --download-superlu_dist "
    EXTRA_OPTS+=" --download-hypre "
  fi
  if [ "$ARCHNAME" != "darwin" ]; then
    EXTRA_OPTS+=" --download-hdf5" # seg faults on OS X
  fi
fi

if [ "$DEBUG" == "0" ]; then
    OPTFLAGS_OPTS="--COPTFLAGS=\"-g -O3 -march=native \" --CXXOPTFLAGS=\"-g -O3 -march=native \" --FOPTFLAGS=\"-g -O3 -march=native \""
else
    OPTFLAGS_OPTS=
fi

if [ "$DOWNLOAD_MPICH" == "1" ]; then
  MPI_OPTS=" --download-mpich"
else
  MPI_OPTS=""
fi

OPTS=" \
PETSC_DIR=$PETSC_DIR \
PETSC_ARCH=$PETSC_ARCH \
--with-debugging=$DEBUG \
--with-precision=$PRECISION \
--with-scalar-type=$SCALARTYPE \
--with-cc=$MYCC \
--with-cxx=$MYCXX \
--with-fc=$MYFC \
$MPI_OPTS \
$BLAS_LAPACK_OPTS \
$OPTFLAGS_OPTS \
$VIENNACL_OPTS \
$C2HTML_OPTS \
$SUITESPARSE_OPTS \
$EXTRA_OPTS \
$CUSTOM_OPTS \
"
printf "Configuring with options:\n"
printf "$OPTS\n"

python2 ./configure $OPTS
