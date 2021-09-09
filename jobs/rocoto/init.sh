#!/bin/ksh -x

###############################################################
## Abstract:
## Get GFS intitial conditions
## RUN_ENVIR : runtime environment (emc | nco)
## HOMEgfs   : /full/path/to/workflow
## EXPDIR : /full/path/to/config/files
## CDATE  : current date (YYYYMMDDHH)
## CDUMP  : cycle name (gdas / gfs)
## PDY    : current date (YYYYMMDD)
## cyc    : current cycle (HH)
###############################################################

###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base getic init"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

###############################################################
# Source machine runtime environment
. $BASE_ENV/${machine}.env init
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Set script and dependency variables

export yy=$(echo $CDATE | cut -c1-4)
export mm=$(echo $CDATE | cut -c5-6)
export dd=$(echo $CDATE | cut -c7-8)
export hh=${cyc:-$(echo $CDATE | cut -c9-10)}

export DATA=${DATA:-${DATAROOT}/init}
export EXTRACT_DIR=${EXTRACT_DIR:-$ROTDIR}
export WORKDIR=${WORKDIR:-$DATA}
export OUTDIR=${OUTDIR:-$ROTDIR}
export COMPONENT="atmos"
export gfs_ver=${gfs_ver:-v16}
export RUNICSH=${RUNICSH:-${GDASINIT_DIR}/run_v16.chgres.sh}

# Check if init is needed and run if so
if [[ $gfs_ver = "v16" && $EXP_WARM_START = ".true." && $CASE = "C768" ]]; then
  echo "Detected v16 C768 warm starts, will not run init. Exiting..."
  exit 0
else
  # Run chgres_cube
  if [ ! -d $OUTDIR ]; then mkdir -p $OUTDIR ; fi
  sh ${RUNICSH} ${CDUMP}
  status=$?
  [[ $status -ne 0 ]] && exit $status
fi

# Check for pgbanl files and move
if [ $gfs_ver = v14 -o $gfs_ver = v15 ]; then
  cd $EXTRACT_DIR
  for grid in 0p25 0p50 1p00
  do
    file=gfs.t${hh}z.pgrb2.${grid}.anl
    if [ -f ${EXTRACT_DIR}/${CDUMP}.${yy}${mm}${dd}/${hh}/${file} ]; then
      mv ${EXTRACT_DIR}/${CDUMP}.${yy}${mm}${dd}/${hh}/${file} ${OUTDIR}/${CDUMP}.${yy}${mm}${dd}/${hh}/${COMPONENT}/${file}
    fi
  done
fi

##########################################
# Remove the Temporary working directory
##########################################
cd $DATAROOT
[[ $KEEPDATA = "NO" ]] && rm -rf $DATA

###############################################################
# Exit out cleanly
exit 0