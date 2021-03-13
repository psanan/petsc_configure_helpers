#!/usr/bin/env sh

working_dir=f90cache
version=f90cache-0.99c
archive=$version.tar.gz
url=https://perso.univ-rennes1.fr/edouard.canot/f90cache/$archive

rm -rf $working_dir
mkdir $working_dir
cd $working_dir
wget $url
tar xzvf $archive

cd $version
./configure
make
#sudo make install
