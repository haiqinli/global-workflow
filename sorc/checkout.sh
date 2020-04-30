#!/bin/sh
set -xu

topdir=$(pwd)
echo $topdir

echo fv3gfs_emc checkout ...
if [[ ! -d fv3gfs_emc.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs_emc.log
    git clone --recursive gerrit:NEMSfv3gfs fv3gfs_emc.fd >> ${topdir}/checkout-fv3gfs_emc.log 2>&1
    cd fv3gfs_emc.fd
    git checkout gfs.v16_PhysicsUpdate
    git submodule update --init --recursive
    cd ${topdir}
else
    echo 'Skip.  Directory fv3gfs_emc.fd already exists.'
fi

echo fv3gfs_ccpp_chem checkout ...
if [[ ! -d fv3gfs_ccpp_chem.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs_ccpp_chem.log
    rm fv3gfs.fd
    git clone --recursive -b gsd/develop https://github.com/haiqinli/ufs-weather-model  fv3gfs_ccpp_chem.fd >> ${topdir}/checkout-fv3gfs_ccpp_chem.log 2>&1
    cd fv3gfs_ccpp_chem.fd
    git checkout badba272cc32f95d79dc2742d457d7fb16423df5
    git submodule sync
    git submodule update --init --recursive
    cd ${topdir}
    ln -fs fv3gfs_ccpp_chem.fd fv3gfs.fd
else
    echo 'Skip.  Directory fv3gfs_ccpp_chem.fd already exists.'
fi

echo fv3gfs_ccpp checkout ...
if [[ ! -d fv3gfs_ccpp.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs_ccpp.log
    git clone --recursive -b gsd/develop https://github.com/NOAA-GSD/ufs-weather-model  fv3gfs_ccpp.fd >> ${topdir}/checkout-fv3gfs_ccpp.log 2>&1
    cd fv3gfs_ccpp.fd
    git checkout 2b5768b19409ba04a37b89833268b7a1d9233139
    git submodule sync
    git submodule update --init --recursive
    cd ${topdir}
    ln -fs fv3gfs_ccpp.fd fv3gfs.fd
else
    echo 'Skip.  Directory fv3gfs_ccpp.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive gerrit:ProdGSI gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
    cd gsi.fd
    git checkout cb8f69d82f38dcf85669b45aaf95dad068f0103c
    git submodule update
    cd ${topdir}
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi

echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${topdir}/checkout-ufs_utils.log
    git clone https://github.com/NOAA-EMC/UFS_UTILS.git ufs_utils.fd >> ${topdir}/checkout-ufs_utils.fd.log 2>&1
    cd ufs_utils.fd
    git checkout v1.1.0
    cd ${topdir}
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_post.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_post.git gfs_post.fd >> ${topdir}/checkout-gfs_post.log 2>&1
    cd gfs_post.fd
    git checkout ba7e59b290c8149ff1c2fee98d01e99e4ef92ee6
    cd ${topdir}
else
    echo 'Skip.  Directory gfs_post.fd already exists.'
fi

echo EMC_gfs_wafs checkout ...
if [[ ! -d gfs_wafs.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_wafs.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_gfs_wafs.git gfs_wafs.fd >> ${topdir}/checkout-gfs_wafs.log 2>&1
    cd gfs_wafs.fd
    git checkout gfs_wafs.v5.0.11
    cd ${topdir}
else
    echo 'Skip.  Directory gfs_wafs.fd already exists.'
fi

echo EMC_verif-global checkout ...
if [[ ! -d verif-global.fd ]] ; then
    rm -f ${topdir}/checkout-verif-global.log
    git clone --recursive gerrit:EMC_verif-global verif-global.fd >> ${topdir}/checkout-verif-global.log 2>&1
    cd verif-global.fd
    git checkout verif_global_v1.2.2
    cd ${topdir}
else
    echo 'Skip. Directory verif-global.fd already exist.'
fi

echo aeroconv checkout ...
if [[ ! -d aeroconv ]] ; then
    rm -f ${topdir}/checkout-aero.log
    git clone https://github.com/NCAR/aeroconv aeroconv >> ${topdir}/checkout-aero.log 2>&1
else
    echo 'Skip.  Directory aeroconv already exists.'
fi

exit 0
