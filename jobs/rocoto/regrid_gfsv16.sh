#! /usr/bin/env bash

source "$HOMEgfs/ush/preamble.sh"

###############################################################
## Abstract:
## Regrid the high resolution Gaussian Met. analysis data (nemsio) into Gaussian model resolution (nemsio)
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current date (YYYYMMDDHH)
## CDUMP  : cycle name (gdas / gfs)
## PDY    : current date (YYYYMMDD)
## cyc    : current cycle (HH)
###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs16_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base regrid"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done
###############################################################
TMPDAY=`$NDATE -24 $PDY$cyc`
HISDAY=`echo $TMPDAY | cut -c1-8`

# Temporary rundirectory
if [ ! -s $DATA ]; then mkdir -p $DATA; fi
cd $DATA || exit 8

res=$(echo $CASE |cut -c2-5)
LONB=$((4*res))
LATB=$((2*res))

mkdir -p regrid
cd regrid

#$JKHNCP $EXECgfs/chgres_recenter_ncio.exe . 
$NCP $EXECgfs/enkf_chgres_recenter_nc.x . 
status=$?
if [ $status -ne 0 ]; then
     echo "error chgres_recenter failed  $status "
     return $status
fi

cat > ./fort.43 << !
 &chgres_setup
  i_output=$LONB
  j_output=$LATB
  input_file="$ICSDIR/$SYEAR$SMONTH$SDAY$SHOUR/$CDUMP/gdas.t${cyc}z.atmanl.nc"
  output_file="atmanl.$SYEAR$SMONTH$SDAY$SHOUR.nc"
  terrain_file="./$CDUMP.t00z.atmf000.nc"
  cld_amt=.F.
  ref_file="./$CDUMP.t00z.atmf000.nc"
 /
!

#JKHmpirun -n 1 ./chgres_recenter_ncio.exe "./fort.43"
mpirun -n 1 ./enkf_chgres_recenter_nc.x "./fort.43"
status=$?
if [ $status -ne 0 ]; then
     echo "error chgres_recenter failed  $status "
     return $status
fi

###############################################################
