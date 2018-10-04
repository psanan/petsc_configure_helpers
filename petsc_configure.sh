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
# You can directly pass any other flags you'd like with CUSTOM_OPTS             #
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

# Language type (only useful for testing)
CLANGUAGE=${CLANGUAGE:-C}

# Compilers
MYCC=${MYCC:-gcc}
MYCXX=${MYCXX:-g++}
MYFC=${MYFC:-gfortran}

# BLAS/LAPACK
DOWNLOAD_BLASLAPACK=${DOWNLOAD_BLASLAPACK:-1}

# MPI
DOWNLOAD_MPICH=${DOWNLOAD_MPICH:-1}

# Construct PETSC_ARCH ##################################################################

# Because of a potential PETSc configure bug, we construct everything but the prepended "arch-"
# in ARCHTAIL
ARCHTAIL=""

# Set the directory to the current directory
PETSC_DIR=$PWD

# Your name for the architecture (say darwin or ubuntu)
# Note: set PDS_PETSC_ARCHNAME in your login file
# Note: the value "darwin" triggers OS X specific settings
ARCHNAME=${ARCHNAME:-$PDS_PETSC_ARCHNAME}
ARCHTAIL+=-$ARCHNAME
if [ "$ARCHMOD" != "" ]; then
  ARCHTAIL+=-$ARCHMOD
fi

if [ "$PRECISION" == "double" ]; then
    ARCHTAIL+=-double
elif [ "$PRECISION" == "single" ]; then
    ARCHTAIL+=-single
elif [ "$PRECISION" == "__float128" ]; then
    ARCHTAIL+=-float128
fi

if [ "$SCALARTYPE" == "complex" ]; then
  ARCHTAIL+=-complex
fi

if [ "$CLANGUAGE" == "C++" ] || [ "$CLANGUAGE" == "c++" ]; then
  ARCHTAIL+=-cpp
fi

if [ "$EXTRA" == "1" ]; then
  ARCHTAIL+=-extra
fi

if [ "$DEBUG" == "1" ]; then
  ARCHTAIL+=-debug
else
  ARCHTAIL+=-opt
fi

if [ "$PREFIX" == "1" ]; then
  ARCHTAIL+=-prefix
fi

PETSC_ARCH=arch$ARCHTAIL

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
  OPTS+=" --with-scalar-type=$SCALARTYPE"
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
if [ "$USE_VIENNACL" == "1" ] && [ "$SCALARTYPE" != "complex" ]; then
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
  OPTS+=" --prefix=$PETSC_DIR/install$ARCHTAIL" # This weird thing is because including PETSC_ARCH caused issues
fi

if [ "$CLANGUAGE" == "C++" ] || [ "$CLANGUAGE" == "c++" ]; then
  OPTS+=" --with-clanguage=c++"
fi

OPTS+=" $CUSTOM_OPTS "

# Print Configure line to copy ##################################################
printf "PETSC_DIR=$PETSC_DIR\n"
printf "PETSC_ARCH=$PETSC_ARCH\n"
printf "Copy and run this\n"
echo python2 ./configure $OPTS
