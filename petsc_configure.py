#!/usr/bin/env python2
#################################################################################
#                       Configuration helper for PETSc                          #
#################################################################################
#                                                                               #
# Execute from PETSC_DIR with Python 2 (used by older versions of PETSc)        #
#                                                                               #
# Run with -h to see arguments                                                  #
#                                                                               #
# Adds a thin extra layer around PETSc's configuration script,                  #
# to help combine commonly-used combinations of configuration options and       #
# construct meaningful PETSC_ARCH values.                                       #
#                                                                               #
# Proceeds by collecting the set of passed arguments and processing them        #
# before sending them to PETSc's configure script.                              #
# This logic will likely be somewhat brittle. Always do a sanity check          #
# and look at the options that are actually being sent. This script should      #
# be simple enough to figure out what's going on.                               #
#                                                                               #
# Patrick Sanan, 2018-2019                                                      #
#################################################################################

# Idea: dump options in root dir, to safeguard against blowing away $PETSC_ARCH dir.
from __future__ import print_function
import sys
import os
import argparse
import re

def main() :
    """ Main script logic """
    args,configure_options_in = get_args()
    configure_options = process_args(configure_options_in,args)
    petsc_configure(configure_options,args)

def get_args() :
    """ Retrieve custom arguments and remaining arguments"""
    parser = argparse.ArgumentParser(description='Compute arguments to pass to PETSc\'s configure script')
    parser.add_argument('--archmod',default=None,help="additional terms in arch name, usually from a branch e.g \"maint\"")
    parser.add_argument('--dryrun',action="store_true",help="don't actually configure")
    parser.add_argument('--extra',type=int,default=1,help="common extra packages (integer value, see script for now) ")
    parser.add_argument('--prefix-auto',action="store_true",help="set --prefix to a standard location (in this directory)")
    args,unknown = parser.parse_known_args()
    return args,unknown

def detect_darwin() :
    return sys.platform == 'darwin'

def process_args(configure_options_in,args) :
    """ Main logic to create a set of options for PETSc's configure script,
    along with a corresponding PETSC_ARCH string, if required """

    # NOTE: the order here is significant, as
    # 1. PETSC_ARCH names are constructed in order
    # 2. Processing of options depends on the processing of previous ones

    # OS X is ornery, so we base many decisions on whether "darwin" is used
    isdarwin = detect_darwin()

    # Initialize options and arch identifiers
    configure_options = configure_options_in[:] #copy
    arch_identifiers  = initialize_arch_identifiers(args)

    # Compilers
    if not get_option_value(configure_options,"--with-cc") and isdarwin :
        configure_options.append('--with-cc=/usr/bin/gcc')
    if not get_option_value(configure_options,"--with-cxx") and isdarwin :
        configure_options.append('--with-cxx=/usr/bin/g++')

    # Floating point precision
    precision = get_option_value(configure_options,"--with-precision")
    if not precision :
        precision = 'double'
    if precision and precision != 'double':
        if precision == '__float128' :
            arch_identifiers.append('quad')
        else :
            arch_identifiers.append(precision)

    # Integer precision
    if get_option_value(configure_options,"--with-64-bit-indices"):
        arch_identifiers.append("int64")

    # Scalar type
    scalartype = get_option_value(configure_options,"--with-scalartype")
    if not scalartype :
        scalartype == 'real'
    if scalartype and scalartype != 'real':
        arch_identifiers.append(scalartype)

    # C language
    clanguage = get_option_value(configure_options,"--with-clanguage")
    if not clanguage :
        clanguage = 'c'
    if clanguage and clanguage != 'c' and clanguage != 'C':
        if clanguage == 'cxx' or clanguage == 'Cxx' or clanguage == 'c++' or clanguage == 'C++':
            arch_identifiers.append('cxx')

    # BLAS/LAPACK
    download_fblaslapack = get_option_value(configure_options,"--download-fblaslapack")
    download_f2cblaslapack = get_option_value(configure_options,"--download-f2cblaslapack")
    if not download_fblaslapack and not download_f2cblaslapack :
        if precision == '__float128' :
            configure_options.append('--download-f2cblaslapack')
        else :
            if not isdarwin :
                configure_options.append('--download-fblaslapack')

    # MPI
    with_mpi = get_option_value(configure_options,"--with-mpi")
    download_mpich = get_option_value(configure_options,"--download-mpich")
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
            download_cmake = get_option_value(configure_options,"--download-cmake")
            if download_cmake == None :
                configure_options.append('--download-cmake')     # for METIS
            configure_options.append('--download-parmetis')
            configure_options.append("--download-mumps")
        if args.extra >= 3:
            configure_options.append("--download-hdf5")
            configure_options.append("--download-superlu_dist")
        if args.extra >= 4:
            if precision == 'double' :
                configure_options.append("--download-sundials")
                configure_options.append("--download-hypre")
                configure_options.append("--download-pastix")
                configure_options.append("--download-ptscotch") # for PASTIX
        if args.extra >= 5:
            configure_options.append("--download-petsc4py")
        if args.extra >=2 :
            arch_identifiers.append('extra')

    # Debugging
    debugging = get_option_value(configure_options,"--with-debugging")
    if debugging == False :
        if not get_option_value(configure_options,"--COPTFLAGS") :
            configure_options.append("--COPTFLAGS=-g -O3")
        if not get_option_value(configure_options,"--CXXOPTFLAGS") :
            configure_options.append("--CXXOPTFLAGS=-g -O3")
        if not get_option_value(configure_options,"--FOPTFLAGS") :
            configure_options.append("--FOPTFLAGS=-g -O3")
        arch_identifiers.append('opt')
    else :
        arch_identifiers.append('debug')

    # C2HTML (for building docs locally)
    with_c2html = get_option_value(configure_options,'--with-c2html')
    download_c2html = get_option_value(configure_options,'--download-c2html')
    if not with_c2html != False and download_c2html != False :
        configure_options.append("--download-c2html")

    # Prefix
    prefix = get_option_value(configure_options,"--prefix")
    if prefix :
        arch_identifiers.append('prefix')

    # Auto-prefix
    # Define an install directory inside the PETSC_DIR (danger for older versions of PETSc?)
    if args.prefix_auto :
        if prefix :
            raise RuntimeError('Cannot use both --prefix and --prefix-auto')
        configure_options.append('--prefix='+os.path.join(os.getcwd(),'-'.join(arch_identifiers)+'-install'))
        arch_identifiers.append('prefix')

    # Add PETSC_ARCH
    configure_options.append('PETSC_ARCH='+'-'.join(arch_identifiers))

    # Use the current directory as PETSC_DIR
    configure_options.append('PETSC_DIR='+os.getcwd())

    return configure_options

def get_option_value(configure_options,key) :
    """ Get the value of a configure option """
    r = re.compile(key+".*")
    matches = list(filter(r.match, configure_options))
    if len(matches) > 1 :
        raise RuntimeError('More than one match for option',key)
    elif len(matches) != 0 :
        match = matches[0]
        if match == key : # interpret exact key as True
            value = True
        else :
            spl = match.split("=")
            if len(spl) < 2 :
                raise RuntimeError('match '+match+' does not seem to have correct --foo=bar format')
            value = spl[1]
    else : # no match
        value = None
    if value == '0' or value == 'false' or value == 'no' :
        value = False
    elif value == '1' or value == 'true' or value == 'yes' :
        value = True
    elif value == '' :
        raise RuntimeError("Don't know how to process "+match)
    return value

def initialize_arch_identifiers(args) :
    """ Create initial arch identifiers """
    arch_identifiers = ['arch']
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
        print('Configuring with these options:')
        print("\n".join(configure_options))
        configure.petsc_configure(configure_options)

if __name__ == '__main__':
    main()
