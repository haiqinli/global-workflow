#!/bin/sh
#set -xue
set -x

while getopts "oc" option;
do
 case $option in
  o)
   echo "Received -o flag for optional checkout of GTG, will check out GTG with UPP"
   checkout_gtg="YES"
   ;;
  c)
   echo "Received -c flag, check out ufs-weather-model develop branch with CCPP physics"  
   run_ccpp="YES"
   ;;
  :)
   echo "option -$OPTARG needs an argument"
   ;;
  *)
   echo "invalid option -$OPTARG, exiting..."
   exit
   ;;
 esac
done

topdir=$(pwd)
echo $topdir

echo fv3gfs checkout ...
if [[ ! -d fv3gfs.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs.log
    if [ ${run_ccpp:-"NO"} = "NO" ]; then
        git clone https://github.com/ufs-community/ufs-weather-model fv3gfs.fd >> ${topdir}/checkout-fv3gfs.log 2>&1
        cd fv3gfs.fd
        git checkout GFS.v16.0.16
    else
        echo ufs-weather-model_24nov_gsldev.fd checkout ...
        if [[ ! -d ufs-weather-model_24nov_0409aa0 ]] ; then
            rm -f ${topdir}/checkout-fv3gfs.log
            git clone --recursive -b gsl/develop https://github.com/NOAA-GSL/ufs-weather-model ufs-weather-model_24nov_0409aa0 >> ${topdir}/checkout-fv3gfs.log 2>&1
            cd ufs-weather-model_24nov_0409aa0
            git checkout 0409aa0e59c0096ade9a2ae85cdbc42b1cf75de3
        else
            echo 'Skip.  Directory ufs-weather-model_24nov_gsldev.fd already exists.'
        fi
    fi
    git submodule update --init --recursive
    cd ${topdir}
    if [ ${run_ccpp:-"NO"} = "YES" ]; then
      ln -fs ufs-weather-model_24nov_0409aa0 fv3gfs.fd
      rsync -avx fv3gfs.fd_gsl/FV3/ fv3gfs.fd/FV3/        ## copy over changes not in FV3 repository
    fi
else
    echo 'Skip.  Directory fv3gfs.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive https://github.com/NOAA-EMC/GSI.git gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
    cd gsi.fd
    git checkout gfsda.v16.0.0
    git submodule update
    cd ${topdir}
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi

echo gldas checkout ...
if [[ ! -d gldas.fd ]] ; then
    rm -f ${topdir}/checkout-gldas.log
    git clone https://github.com/NOAA-EMC/GLDAS.git gldas.fd >> ${topdir}/checkout-gldas.fd.log 2>&1
    cd gldas.fd
    git checkout gldas_gfsv16_release.v1.13.0
    cd ${topdir}
else
    echo 'Skip.  Directory gldas.fd already exists.'
fi

echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${topdir}/checkout-ufs_utils.log
    git clone https://github.com/NOAA-EMC/UFS_UTILS.git ufs_utils.fd >> ${topdir}/checkout-ufs_utils.fd.log 2>&1
    cd ufs_utils.fd
    git checkout ufs_utils_1_4_0
#    git checkout ops-gfsv16.0.0
    cd ${topdir}
    rsync -ax ufs_utils.fd_gsl/ ufs_utils.fd/        ## copy over changes not in UFS_UTILS repository
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo UPP checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_post.log
    git clone https://github.com/NOAA-EMC/UPP.git gfs_post.fd >> ${topdir}/checkout-gfs_post.log 2>&1
    cd gfs_post.fd
    git checkout upp_gfsv16_release.v1.1.1
    ################################################################################
    # checkout_gtg
    ## yes: The gtg code at NCAR private repository is available for ops. GFS only.
    #       Only approved persons/groups have access permission.
    ## no:  No need to check out gtg code for general GFS users.
    ################################################################################
    checkout_gtg=${checkout_gtg:-"NO"}
    if [[ ${checkout_gtg} == "YES" ]] ; then
      ./manage_externals/checkout_externals
      cp sorc/post_gtg.fd/*f90 sorc/ncep_post.fd/.
      cp sorc/post_gtg.fd/gtg.config.gfs parm/gtg.config.gfs
    fi
    cd ${topdir}
    rsync -ax gfs_post.fd_gsl/ gfs_post.fd/        ## copy over GSL changes not in UPP repository
else
    echo 'Skip.  Directory gfs_post.fd already exists.'
fi

echo EMC_gfs_wafs checkout ...
if [[ ! -d gfs_wafs.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_wafs.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_gfs_wafs.git gfs_wafs.fd >> ${topdir}/checkout-gfs_wafs.log 2>&1
    cd gfs_wafs.fd
    git checkout gfs_wafs.v6.0.17
    cd ${topdir}
else
    echo 'Skip.  Directory gfs_wafs.fd already exists.'
fi

echo EMC_verif-global checkout ...
if [[ ! -d verif-global.fd ]] ; then
    rm -f ${topdir}/checkout-verif-global.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_verif-global.git verif-global.fd >> ${topdir}/checkout-verif-global.log 2>&1
    cd verif-global.fd
    git checkout verif_global_v1.13.1
    cd ${topdir}
else
    echo 'Skip. Directory verif-global.fd already exist.'
fi

echo aeroconv checkout ...
if [[ ! -d aeroconv.fd ]] ; then
    rm -f ${topdir}/checkout-aero.log
    git clone https://github.com/NCAR/aeroconv aeroconv.fd >> ${topdir}/checkout-aero.log 2>&1
    cd aeroconv.fd
    git checkout 24f6ddc
    cd ${topdir}
    ./aero_extract.sh
else
    echo 'Skip.  Directory aeroconv.fd already exists.'
fi

exit 0
