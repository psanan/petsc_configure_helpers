ARCHNAME=darwin

CUSTOM_OPTS+=" --download-c2html --download-sowing " #space at the beginning is important

SRCDIR=$(dirname "$0")
source $SRCDIR/petsc_configure_common.sh
