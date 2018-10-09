#!/usr/bin/env python
#################################################################################
#                       Configuration helper for PETSc                          #
#################################################################################
#
# Execute from PETSC_DIR
#
# Run with -h to see arguments
#
# Adds a thin extra layer around PETSc's configuration script,
# to help combine commonly-used combinations of configuration options and
# construct meaningful PETSC_ARCH values.
#
# Proceeds by collecting the set of passed arguments and processing them
# before sending them to PETSc's configure script.
# This logic will likely be somewhat brittle. Always do a sanity check
# and look at the options that are actually being sent. This script should
# be simple enough to figure out what's going on.
#
# by Patrick Sanan, 2018
#
#################################################################################

from __future__ import print_function
import sys
import os
import argparse
import re

def main() :
    args,configure_options_in = get_args()
    configure_options = process_args(configure_options_in,args)
    petsc_configure(configure_options,args)

def get_args() :
    """ Retrieve custom arguments """
    parser = argparse.ArgumentParser(description='Compute arguments to pass to PETSc\'s configure script')
    parser.add_argument('--dryrun',action="store_true",help="don't actually configure")
    parser.add_argument('--extra',type=int,default=1,help="common extra packages (integer value, see script for now) ")
    parser.add_argument('--archname',default=get_arch_name(),help="arch name, picked up from PDS_PETSC_ARCHNAME")
    parser.add_argument('--archmod',default=None,help="additional terms in arch name, usually from a branch e.g \"maint\"")
    args,unknown = parser.parse_known_args()
    return args,unknown

def get_arch_name() :
    PDS_PETSC_ARCHNAME=os.getenv('PDS_PETSC_ARCHNAME')
    if PDS_PETSC_ARCHNAME :
        return PDS_PETSC_ARCHNAME
    else :
        return None

def process_args(configure_options_in,args) :
    """ Main logic to create a set of options for PETSc's configure script,
    along with a corresponding PETSC_ARCH string """

    # NOTE: the order here is important, as
    # 1. PETSC_ARCH names are constructed in order
    # 2. Processing of options depends on the processing of previous ones

    # Initialize configure_options
    configure_options = configure_options_in[:] #copy

    # Initialize options and arch identifiers
    arch_identifiers = initialize_arch_identifiers(args)

    # Precision
    precision=get_option_value(configure_options,"--with-precision")
    if precision :
        if precision == '__float128' :
            arch_identifiers.append('quad')
        else :
            arch_identifiers.append(precision)

    # Scalar type
    scalartype=get_option_value(configure_options,"--with-scalartype")
    if scalartype :
        arch_identifiers.append(scalartype)

    # C language
    clanguage=get_option_value(configure_options,"--with-clanguage")
    if clanguage :
        if clanguage == 'cxx' or clanguage == 'Cxx' or clanguage == 'c++' or clanguage == 'C++':
            arch_identifiers.append('cxx')

    # Debugging
    debugging=get_option_value(configure_options,"--with-debugging")
    if debugging == False :
        configure_options.append("--COPTFLAGS=\"-g -O3 -march=native\"")
        configure_options.append("--CXXOPTFLAGS=\"-g -O3 -march=native\"")
        configure_options.append("--FOPTFLAGS=\"-g -O3 -march=native\"")
        arch_identifiers.append('opt')
    else :
        arch_identifiers.append('debug')

    # BLAS/LAPACK
    download_fblaslapack=get_option_value(configure_options,"--download-fblaslapack")
    download_f2blaslapack=get_option_value(configure_options,"--download-f2cblaslapack")
    if download_fblaslapack != False and download_f2blaslapack != False :
        if precision == '__float128' :
            configure_options.append('--download-f2blaslapack')
        else :
            configure_options.append('--download-fblaslapack')

    # MPI
    with_mpi=get_option_value(configure_options,"--with-mpi")
    download_mpich=get_option_value(configure_options,"--download-mpich")
    if with_mpi != False and download_mpich != False :
        configure_options.append('--download-mpich')

    # Extra packages
    if args.extra :
        if args.extra >= 1:
            if scalartype != 'complex' :
                configure_options.append('--download-suitesparse')
        if args.extra >= 2:
            configure_options.append('--download-scalapack')
            configure_options.append('--download-metis')
            configure_options.append('--download-parmetis')
            configure_options.append("--download-mumps")
            if precision != 'single' and precision != 'double' :
                configure_options.append("--download-sundials")
                configure_options.append("--download-superlu_dist")
                configure_options.append("--download-hypre")
        if args.extra >= 3:
            configure_options.append("--download-hdf5")
        if args.extra >=2 :
            arch_identifiers.append('extra')

    # Use the current directory as PETSC_DIR
    configure_options.append('PETSC_DIR='+os.getcwd())

    # Create the final PETSC_ARCH string and add to configure options
    configure_options.append('PETSC_ARCH='+'-'.join(arch_identifiers))

    return configure_options

def get_option_value(configure_options,key) :
    """ Get the value of a configure option expected to have a value """
    r = re.compile(key+".*")
    matches = list(filter(r.match, configure_options))
    if len(matches) > 1 :
        raise RuntimeError('More than one match for option',key)
    elif len(matches) != 0 :
        match = matches[0]
        spl = match.split("=")
        if len(spl) < 2 :
            raise RuntimeError('match'+match+'does not seem to have correct --foo=bar format')
        value = spl[1]
    else :
        value = None
    if value == '0' or value == 'false' or value == 'no' :
        value = False
    if value == '1' or value == 'true' or value == 'yes' or value == '' :
        value = True
    return value

def initialize_arch_identifiers(args) :
    """ Create initial arch identifiers """
    arch_identifiers = ['arch']
    if args.archname :
        arch_identifiers.append(args.archname)
    if args.archmod :
        arch_identifiers.append(args.archmod)
    return arch_identifiers

def petsc_configure(configure_options,args) :
  """ Standard PETSc configuration script logic (from config/examples) """
  if (args.dryrun) :
      print("Dry Run. Would configure with these options:")
      print("\n".join(configure_options))
  else :
      sys.path.insert(0,os.path.abspath('config'))
      try :
          import configure
      except ImportError :
          print('PETSc configure module not found. Make sure you are executing from PETSC_DIR')
          sys.exit(1)
      print('Configuring with these options (make sure they are sane!)')
      print("\n".join(configure_options))
      configure.petsc_configure(configure_options)

if __name__ == '__main__':
    main()
