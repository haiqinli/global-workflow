#!/bin/sh
set -xue

while getopts "o" option;
do
 case $option in
  o)
   echo "Received -o flag for optional checkout of GTG, will check out GTG with EMC_post"
   checkout_gtg="YES"
   checkout_wafs="YES"
   gtg_git_args="--recursive"
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

echo fv3gfs_ccpp_chem checkout ...
if [[ ! -d fv3gfs_ccpp_chem.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs_ccpp_chem.log
   git clone --recursive --branch gsd/develop-chem https://github.com/NOAA-GSL/ufs-weather-model  fv3gfs_ccpp_chem.fd >> ${topdir}/checkout-fv3gfs_ccpp_chem.log 2>&1
   cd fv3gfs_ccpp_chem.fd
   git checkout ea18809250e4de0fa410fceecad50415460bb8ca 
   git submodule sync
   git submodule update --init --recursive
   cd ${topdir}
   ln -fs fv3gfs_ccpp_chem.fd fv3gfs.fd
else
    echo 'Skip.  Directory fv3gfs_ccpp_chem.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${topdir}/checkout-gsi.log
    git clone --recursive --branch gfsda.v16.2.0.1 https://github.com/NOAA-EMC/GSI.git gsi.fd >> ${topdir}/checkout-gsi.log 2>&1
    cd gsi.fd
    git submodule update --init
    cd ${topdir}
    rsync -ax gsi.fd_chem/ gsi.fd/
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi

echo gldas checkout ...
if [[ ! -d gldas.fd ]] ; then
    rm -f ${topdir}/checkout-gldas.log
    git clone --branch gldas_gfsv16_release.v.2.1.0 https://github.com/NOAA-EMC/GLDAS  gldas.fd >> ${topdir}/checkout-gldas.fd.log 2>&1
    cd ${topdir}
else
    echo 'Skip.  Directory gldas.fd already exists.'
fi

echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${topdir}/checkout-ufs_utils.log
    git clone --branch ops-gfsv16.2.1 https://github.com/ufs-community/UFS_UTILS ufs_utils.fd >> ${topdir}/checkout-ufs_utils.fd.log 2>&1
    cd ${topdir}
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo prepchem_NC.fd checkout ...
if [[ ! -d prepchem_NC.fd ]] ; then
    rm -f ${topdir}/checkout-prepchem_NC.fd.log
    git clone  gerrit:GSD-prep-chem prepchem_NC.fd >> ${topdir}/checkout-prepchem_NC.fd.log 2>&1
    cd ${topdir}
else
    echo 'Skip.  Directory prechem_NC.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_post.log
    git clone ${gtg_git_args:-} --branch upp_v8.1.2 https://github.com/NOAA-EMC/UPP.git gfs_post.fd >> ${topdir}/checkout-gfs_post.log 2>&1
    ################################################################################
    # checkout_gtg
    ## yes: The gtg code at NCAR private repository is available for ops. GFS only.
    #       Only approved persons/groups have access permission.
    ## no:  No need to check out gtg code for general GFS users.
    ################################################################################
    checkout_gtg=${checkout_gtg:-"NO"}
    if [[ ${checkout_gtg} == "YES" ]] ; then
      cd gfs_post.fd
      cp sorc/post_gtg.fd/*f90 sorc/ncep_post.fd/.
      cp sorc/post_gtg.fd/gtg.config.gfs parm/gtg.config.gfs
    fi
    cd ${topdir}
else
    echo 'Skip.  Directory gfs_post.fd already exists.'
fi

checkout_wafs=${checkout_wafs:-"NO"}
if [[ ${checkout_wafs} == "YES" ]] ; then
  echo EMC_gfs_wafs checkout ...
  if [[ ! -d gfs_wafs.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_wafs.log
    git clone --recursive --branch gfs_wafs.v6.2.8 https://github.com/NOAA-EMC/EMC_gfs_wafs.git gfs_wafs.fd >> ${topdir}/checkout-gfs_wafs.log 2>&1
    cd ${topdir}
  else
    echo 'Skip.  Directory gfs_wafs.fd already exists.'
  fi
fi

echo EMC_verif-global checkout ...
if [[ ! -d verif-global.fd ]] ; then
    rm -f ${topdir}/checkout-verif-global.log
    git clone --recursive --branch verif_global_v2.10.0 https://github.com/NOAA-EMC/EMC_verif-global.git verif-global.fd >> ${topdir}/checkout-verif-global.log 2>&1
    cd ${topdir}
else
    echo 'Skip. Directory verif-global.fd already exist.'
fi

exit 0
