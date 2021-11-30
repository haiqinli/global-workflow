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

echo ufs-weather-model_18nov_gsldev.fd checkout ...
if [[ ! -d ufs-weather-model_18nov_c71001e ]] ; then
    rm -f ${topdir}/checkout-18nov.log
    git clone --recursive -b gsl/develop https://github.com/NOAA-GSL/ufs-weather-model ufs-weather-model_18nov_c71001e >> ${topdir}/checkout-18nov.log 2>&1
    cd ufs-weather-model_18nov_c71001e
    git checkout c71001e2b488a41b736f403c2ffa26526eaeb77c 
    git submodule update --init --recursive
    cd ${topdir}
else
    echo 'Skip.  Directory ufs-weather-model_18nov_gsldev.fd already exists.'
fi

exit 0
