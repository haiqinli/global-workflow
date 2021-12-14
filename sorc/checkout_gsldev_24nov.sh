#!/bin/sh
#set -xue
set -x

while getopts "oc" option;
do
 case $option in
  o)
   echo "Received -o flag for optional checkout of GTG, will check out GTG with EMC_post"
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

echo ufs-weather-model_24nov_gsldev.fd checkout ...
if [[ ! -d ufs-weather-model_24nov_0409aa0 ]] ; then
    rm -f ${topdir}/checkout-24nov.log
    git clone --recursive -b gsl/develop https://github.com/NOAA-GSL/ufs-weather-model ufs-weather-model_24nov_0409aa0 >> ${topdir}/checkout-24nov.log 2>&1
    cd ufs-weather-model_24nov_0409aa0
    git checkout 0409aa0e59c0096ade9a2ae85cdbc42b1cf75de3
    git submodule update --init --recursive
    cd ${topdir}
    if [ ${run_ccpp:-"NO"} = "YES" ]; then
      ln -fs ufs-weather-model_24nov_0409aa0 fv3gfs.fd
      rsync -avx fv3gfs.fd_gsl/FV3/ fv3gfs.fd/FV3/        ## copy over changes not in FV3 repository
    fi
else
    echo 'Skip.  Directory ufs-weather-model_24nov_gsldev.fd already exists.'
fi

exit 0
