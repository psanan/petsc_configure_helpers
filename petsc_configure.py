#!/usr/bin/env python2
""" Configuration helper for PETSc

Execute from PETSC_DIR

Note that older version of PETSc require Python 2

Run with -h to see arguments

Adds a thin extra layer around PETSc's configuration script,
to help combine commonly-used combinations of configuration options and
construct meaningful PETSC_ARCH values.

Proceeds by collecting the set of passed arguments and processing them
before sending them to PETSc's configure script.
This logic will likely be somewhat brittle. Always do a sanity check
and look at the options that are actually being sent. This script should
be simple enough to figure out what's going on.

Patrick Sanan, 2018-2020
"""

from __future__ import print_function
import sys
import os
import argparse
import re


def main():
    """ Main script logic """
    args, options_in = get_args()
    options = process_args(options_in, args)
    petsc_configure(options, args)


def get_args():
    """ Retrieve custom arguments and remaining arguments"""
    parser = argparse.ArgumentParser(
        description='Compute arguments to pass to PETSc\'s configure script')
    parser.add_argument(
        '--archmod',
        default=None,
        help="additional terms in arch name, usually from a branch e.g \"maint\"")
    parser.add_argument(
        '--dryrun',
        action="store_true",
        help="don't actually configure")
    parser.add_argument(
        '--extra',
        type=int,
        default=1,
        help="common extra packages (integer value, see script for now) ")
    parser.add_argument(
        '--prefix-auto',
        action="store_true",
        help="set --prefix to a standard location (in this directory)")
    parser.add_argument(
        '--mpich-only',
        action="store_true",
        help="Custom options to simply obtain MPICH, to use elsewhere")
    args, unknown = parser.parse_known_args()
    return args, unknown


def _detect_darwin():
    return sys.platform == 'darwin'


def process_args(options_in, args):
    """ Main logic to create a set of options for PETSc's configure script,
    along with a corresponding PETSC_ARCH string, if required """

    # NOTE: the order here is significant, as
    # 1. PETSC_ARCH names are constructed in order
    # 2. Processing of options depends on the processing of previous ones

    # A special case
    mpich_only_arch = 'arch-mpich-only'
    if args.mpich_only:
        return options_for_mpich_only(mpich_only_arch)

    # OS X is ornery, so we base many decisions on whether "darwin" is used
    # In particular, building external packages with compilers other
    # than OS X's compilers (/usr/bin/gcc and /usr/bin/g++) is problematic
    is_darwin = _detect_darwin()

    # Initialize options and arch identifiers
    options = options_in[:]  #copy
    arch_identifiers = initialize_arch_identifiers(args)

    # Floating point precision
    precision = get_option_value(options, "--with-precision")
    if not precision:
        precision = 'double'
    if precision and precision != 'double':
        if precision == '__float128':
            arch_identifiers.append('quad')
        else:
            arch_identifiers.append(precision)

    # MPI
    # By default, we expect you to have $HOME/code/petsc/arch-mpich-only,
    # which you created with this script.
    with_mpi = get_option_value(options, "--with-mpi")
    with_mpi_dir = get_option_value(options, "--with-mpi-dir")
    download_mpich = get_option_value(options, "--download-mpich")
    if with_mpi != False and not with_mpi_dir and not download_mpich:
        mpich_only_petsc_dir = os.path.join(os.environ['HOME'], 'code', 'petsc')
        mpich_only_dir = os.path.join(mpich_only_petsc_dir, mpich_only_arch)
        if not os.path.isdir(mpich_only_dir):
            print('Did not find expected', mpich_only_dir)
            print('Either run this script with --mpich-only from', mpich_only_petsc_dir)
            print('Or specify MPI some other way, e.g. --download-mpich')
            sys.exit(1)
        options.append('--with-mpi-dir=' + mpich_only_dir)

    # Fortran bindings
    with_fortran_bindings = get_option_value(options, "--with-fortran-bindings")
    if with_fortran_bindings is None:
        options.append('--with-fortran-bindings=0')

    # Integer precision
    if get_option_value(options, "--with-64-bit-indices"):
        arch_identifiers.append("int64")

    # Scalar type
    scalartype = get_option_value(options, "--with-scalar-type")
    if not scalartype:
        scalartype = 'real'
    if scalartype and scalartype != 'real':
        arch_identifiers.append(scalartype)
        options.append("--with-scalar-type=%s" % scalartype)

    # C language
    clanguage = get_option_value(options, "--with-clanguage")
    if not clanguage:
        clanguage = 'c'
    if clanguage and clanguage != 'c' and clanguage != 'C':
        if clanguage == 'cxx' or clanguage == 'Cxx' or clanguage == 'c++' or clanguage == 'C++':
            arch_identifiers.append('cxx')

    # BLAS/LAPACK
    download_fblaslapack = get_option_value(options,
                                            "--download-fblaslapack")
    download_f2cblaslapack = get_option_value(options,
                                              "--download-f2cblaslapack")
    if not download_fblaslapack and not download_f2cblaslapack:
        if precision == '__float128':
            options.append('--download-f2cblaslapack')

    # Extra packages
    if args.extra:
        if args.extra >= 1:
            if scalartype is 'real' and precision is 'double':
                options.append('--download-suitesparse')
            options.append('--download-yaml')
        if args.extra >= 2:
            options.append('--download-scalapack')
            options.append('--download-metis')
            download_cmake = get_option_value(options, '--download-cmake')
            if download_cmake is None:
                options.append('--download-cmake')  # for METIS
            options.append('--download-parmetis')
            options.append('--download-mumps')
        if args.extra >= 3:
            options.append('--download-hdf5')
            options.append('--download-superlu_dist')
            with_cuda = get_option_value(options, "--with-cuda")
            if with_cuda:
                options.append('--with-openmp=1')  # for SuperLU_dist GPU
        if args.extra >= 2:
            arch_identifiers.append('extra')

    # Debugging
    debugging = get_option_value(options, "--with-debugging")
    if debugging is None or debugging:
        arch_identifiers.append('debug')
    else:
        if not get_option_value(options, "--COPTFLAGS"):
            options.append("--COPTFLAGS=-g -O3 -march=native")
        if not get_option_value(options, "--CXXOPTFLAGS"):
            options.append("--CXXOPTFLAGS=-g -O3 -march=native")
        if not get_option_value(options, "--FOPTFLAGS"):
            options.append("--FOPTFLAGS=-g -O3 -march=native")
        if not get_option_value(options, "--CUDAOPTFLAGS"):
            options.append("--CUDAOPTFLAGS=-O3")
        arch_identifiers.append('opt')

    # C2HTML (for building docs locally)
    with_c2html = get_option_value(options, '--with-c2html')
    download_c2html = get_option_value(options, '--download-c2html')
    if not with_c2html != False and download_c2html != False:
        options.append("--download-c2html")

    # Prefix
    prefix = get_option_value(options, "--prefix")
    if prefix:
        arch_identifiers.append('prefix')

    # Auto-prefix
    # Define an install directory inside the PETSC_DIR (danger for older versions of PETSc?)
    if args.prefix_auto:
        if prefix:
            raise RuntimeError('Cannot use both --prefix and --prefix-auto')
        options.append(
            '--prefix=' +
            os.path.join(os.getcwd(), '-'.join(arch_identifiers) + '-install'))
        arch_identifiers.append('prefix')

    # Add PETSC_ARCH
    options.append('PETSC_ARCH=' + '-'.join(arch_identifiers))

    # Use the current directory as PETSC_DIR
    options.append('PETSC_DIR=' + os.getcwd())

    return options


def get_option_value(options, key):
    """ Get the value of a configure option """
    regexp = re.compile(key)
    matches = list(filter(regexp.match, options))
    # FIXME this doesn't work with e.g. --with-cuda=1 --with-cuda-dir=foo:
    if len(matches) > 1:
        raise RuntimeError('More than one match for option', key)
    elif matches:
        match = matches[0]
        if match == key:  # interpret exact key as True
            value = True
        else:
            spl = match.split("=", 1)
            if len(spl) != 2:
                raise RuntimeError(
                    'match ' + match +
                    ' does not seem to have correct --foo=bar format')
            value = spl[1]
    else:  # no match
        value = None
    if value == '0' or value == 'false' or value == 'no':
        value = False
    elif value == '1' or value == 'true' or value == 'yes':
        value = True
    elif value == '':
        raise RuntimeError("Don't know how to process " + match)
    return value


def initialize_arch_identifiers(args):
    """ Create initial arch identifiers """
    arch_identifiers = ['arch']
    if args.archmod:
        arch_identifiers.append(args.archmod)
    return arch_identifiers


def options_for_mpich_only(mpich_only_arch):
    """ Return a custom set of arguments to simply download and build MPICH """
    options = []
    options.append('--download-mpich')
    if _detect_darwin():
        options.append('--with-cc=ccache /usr/bin/gcc')
        options.append('--with-cxx=ccache /usr/bin/g++')
    else:
        options.append('--with-cc=ccache gcc')
        options.append('--with-cxx=ccache g++')
    options.append('--with-fc=ccache gfortran')
    options.append('--with-x=0')
    options.append('--with-debugging=0')
    options.append("--COPTFLAGS=-g -O3")
    options.append("--CXXOPTFLAGS=-g -O3")
    options.append("--FOPTFLAGS=-g -O3")
    options.append('PETSC_ARCH=' + mpich_only_arch)
    options.append('PETSC_DIR=' + os.getcwd())
    return options


def petsc_configure(options, args):
    """ Standard PETSc configuration script logic (from config/examples) """
    if args.dryrun:
        print("Dry Run. Would configure with these options:")
        print("\n".join(options))
    else:
        sys.path.insert(0, os.path.abspath('config'))
        try:
            import configure
        except ImportError:
            print(
                'PETSc configure module not found. Make sure you are executing from PETSC_DIR'
            )
            sys.exit(1)
        print('Configuring with these options:')
        print("\n".join(options))
        configure.petsc_configure(options)


if __name__ == '__main__':
    main()
