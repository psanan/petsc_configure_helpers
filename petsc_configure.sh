#################################################################################
#                       Configuration helper for PETSc                          #
#################################################################################
# Run this from PETSC_DIR.                                                      #
#                                                                               #
# For the optimized configuration of the maint branch, use                      #
#                                                                               #
#     DEBUG=0 ARCHMOD=maint /path/to/here/petsc_configure.sh                    #
#                                                                               #
# for a version with debugging and extra packages                               #
#                                                                               #
#     EXTRA=1 ARCHMOD=maint /path/to/here/petsc_configure_common.sh             #
#                                                                               #
# You can also provide things like PRECISION, SCALARTYPE, etc.                  #
# You can directly pass any other flags you'd like with CUSTOMS_OPTS            #
# Supply PREFIX=1 to set a standard prefix location                             #
#                                                                               #
#################################################################################

# Set defaults ##################################################################

# Add an arbitrary modifier to the arch
# this is useful if you want an arch that corresponds to a
# specific branch (like maint). We recommend that you always do this.
ARCHMOD=${ARCHMOD:-}

# Set Precision
PRECISION=${PRECISION:-double}

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

# Debugging
DEBUG=${DEBUG:-1}

# Set scalar type (real or complex)
SCALARTYPE=${SCALARTYPE:-real}

# Compilers
MYCC=${MYCC:-gcc}
MYCXX=${MYCXX:-g++}
MYFC=${MYFC:-gfortran}

# BLAS/LAPACK
DOWNLOAD_BLASLAPACK=${DOWNLOAD_BLASLAPACK:-1}

# MPI
DOWNLOAD_MPICH=${DOWNLOAD_MPICH:-1}

# Construct PETSC_ARCH ##################################################################

# Set the directory to the current directory
PETSC_DIR=$PWD

# Construct our PETSC_ARCH as a root plus some modifiers
PETSC_ARCH_ROOT=arch
PETSC_ARCH=$PETSC_ARCH_ROOT

# Your name for the architecture (say darwin or ubuntu)
# Note: set PDS_PETSC_ARCHNAME in your login file
# Note: the value "darwin" triggers OS X specific settings
ARCHNAME=${ARCHNAME:-$PDS_PETSC_ARCHNAME}
PETSC_ARCH+=-$ARCHNAME
if [ "$ARCHMOD" != "" ]; then
  PETSC_ARCH+=-$ARCHMOD
fi

if [ "$PRECISION" == "double" ]; then
    PETSC_ARCH+=-double
elif [ "$PRECISION" == "single" ]; then
    PETSC_ARCH+=-single
elif [ "$PRECISION" == "__float128" ]; then
    PETSC_ARCH+=-float128
fi

if [ "$EXTRA" == "1" ]; then
  PETSC_ARCH+=-extra
fi

if [ "$SCALARTYPE" == "complex" ]; then
  PETSC_ARCH+=-complex
fi

if [ "$DEBUG" == "1" ]; then
  PETSC_ARCH+=-debug
else
  PETSC_ARCH+=-opt
fi

if [ "$PREFIX" == "1" ]; then
  PETSC_ARCH+=-prefix
fi

# Construct configure options ###########################################################

OPTS="\
PETSC_DIR=$PETSC_DIR \
PETSC_ARCH=$PETSC_ARCH \
--with-cc=$MYCC \
--with-cxx=$MYCXX \
--with-fc=$MYFC \
"

if [ "$PRECISION" != "double" ]; then
  OPTS+=" --with-precision=$PRECISION"
fi

if [ "$SCALARTYPE" != "real" ]; then
  OPTS+=" --with-scalartype=$SCALARTYPE"
fi

# Use PRECISION to choose an appropriate BLAS/LAPACK
if [ "DOWNLOAD_BLASLAPACK" == "1" ]; then
  if [ "$PRECISION" == "__float128" ]; then
      OPTS+=" --download-f2cblaslapack"
  else
      OPTS+=" --download-fblaslapack"
  fi
fi

# Note that this is a bit non-intuitive using viennacl-dev, as we specify an empty lib location
if [ "$USE_VIENNACL" == "1" ] && [ "$SCALARTYPE" != "complex" ] ; then
  OPTS+=" --with-opencl"
  if [ "$VIENNACL_DEV" == "1" ]]; then
    OPTS+=" --with-viennacl=1 --with-viennacl-include=../viennacl-dev --with-viennacl-lib= "
  else
    OPTS+=" --download-viennacl "
  fi
fi

if [ "$ARCHNAME" == "darwin" ]; then
  OPTS+=" --download-c2html --download-sowing"
fi

if [ "$USE_SUITESPARSE" == "1" ] && [ "$PRECISION" == "double" ]; then
  OPTS+=" --download-suitesparse"
fi

if [ "$EXTRA" == "1" ]; then
  OPTS+=" --download-yaml"
  OPTS+=" --download-scalapack --download-metis --download-parmetis --download-mumps"
  #OPTS+=" --download-ptscotch --download-pastix"
  if [ "$PRECISION" == "double" ]; then
    OPTS+=" --download-sundials "
    OPTS+=" --download-superlu_dist "
    OPTS+=" --download-hypre "
  fi
  if [ "$ARCHNAME" != "darwin" ]; then
    OPTS+=" --download-hdf5" # seg faults on OS X
  fi
fi

if [ "$DEBUG" != "1" ]; then
  OPTS+=" --with-debugging=0 --COPTFLAGS=\"-g -O3 -march=native \" --CXXOPTFLAGS=\"-g -O3 -march=native \" --FOPTFLAGS=\"-g -O3 -march=native \""
fi

if [ "$DOWNLOAD_MPICH" == "1" ]; then
  OPTS+=" --download-mpich"
fi

if [ "$PREFIX" == "1" ]; then
  OPTS+=" --prefix=$PETSC_DIR/$PETSC_ARCH-install"
fi

# Print and Configure ###########################################################
printf "PETSC_DIR=$PETSC_DIR\n"
printf "PETSC_ARCH=$PETSC_ARCH\n"
printf "Configuring with options:\n"
printf "$OPTS\n\n"

python2 ./configure $OPTS
