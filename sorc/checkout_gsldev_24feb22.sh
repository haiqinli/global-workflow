#!/bin/sh
#set -xue
set -x

topdir=$(pwd)
echo $topdir

echo ufs-weather-model_24feb22_gsldev.fd checkout ...
if [[ ! -d ufs-weather-model_24feb22_a2a6a22 ]] ; then
    rm -f ${topdir}/checkout-24feb22.log
    git clone --recursive -b gsl/develop https://github.com/NOAA-GSL/ufs-weather-model ufs-weather-model_24feb22_a2a6a22 >> ${topdir}/checkout-24feb22.log 2>&1
    cd ufs-weather-model_24feb22_a2a6a22 
    git checkout a2a6a22b865d471a2814712ea80bef946d30bd2d 
    git submodule update --init --recursive
    cd ${topdir}
    ln -fs ufs-weather-model_24feb22_a2a6a22 fv3gfs.fd
    rsync -avx fv3gfs.fd_gsl/FV3/ fv3gfs.fd/FV3/        ## copy over changes not in FV3 repository
else
    echo 'Skip.  Directory ufs-weather-model_24feb22_gsldev.fd already exists.'
fi

exit 0
