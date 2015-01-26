#!/bin/bash
if [ $# -lt 1 ]; then
  echo "Usage: $0 PETSC_ARCH (PETSC_DIR)"
  exit 1
fi
if [ $# -lt 2 ]; then
  export PETSC_DIR="/Users/sascha/Documents/codes/PETSc/petsc-dev"
else
  export PETSC_DIR="$2"
fi
export PETSC_ARCH="$1"
petscenvprint.sh
