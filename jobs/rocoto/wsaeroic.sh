#!/bin/bash

###############################################################
# Source relevant configs
configs="base"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

# initialize
AERO_DIR=${HOMEgfs}/sorc/aeroconv.fd
module purge
module load intel/18.0.5.274
module load impi/2018.4.274
module load hdf5/1.10.4
module load netcdf/4.6.1
module load udunits/2.1.24
module load ncl/6.5.0
module use -a /contrib/anaconda/modulefiles
module load anaconda/2.0.1

export LD_PRELOAD=$AERO_DIR/thirdparty/lib/libjpeg.so
export PATH=$AERO_DIR/thirdparty/bin:$PATH
export LD_LIBRARY_PATH=$AERO_DIR/thirdparty/lib:$AERO_DIR/thirdparty/lib64:$LD_LIBRARY_PATH
export PYTHONPATH=$AERO_DIR/thirdparty/lib/python2.7/site-packages:$PYTHONPATH

#
echo
echo "FIXfv3 = $FIXfv3"
echo "CDATE = $CDATE"
echo "CDUMP = $CDUMP"
echo "CASE = $CASE"
echo "AERO_DIR = $AERO_DIR"
echo "WSICS_DIR = $WSICS_DIR"
echo

# Temporary runtime directory
export DATA="$DATAROOT/aerofv3ic$$"
[[ -d $DATA ]] && rm -rf $DATA
mkdir -p $DATA/INPUT
cd $DATA
echo entering $DATA....

export OUTDIR="$WSICSDIR/$CDATE/$CDUMP/RESTART"

# link files
ln -sf ${AERO_DIR}/thirdparty 
ln -sf ${WSICS_DIR}/../../../../gfs_ctrl.nc INPUT       
for num in `seq 1 6`; do
  ln -sf ${WSICS_DIR}/${CDATE}.000000.fv_tracer.res.tile${num}.nc INPUT/gfs_data.tile${num}.nc
  ln -sf ${FIXfv3}/${CASE}/${CASE}_grid_spec.tile${num}.nc INPUT/grid_spec.tile${num}.nc
done
ln -sf ${AERO_DIR}/INPUT/QNWFA_QNIFA_SIGMA_MONTHLY.dat.nc INPUT

cp ${AERO_DIR}/int2nc_to_nggps_ic_* ./ 

yyyymmdd=`echo $CDATE | cut -c1-8`
./int2nc_to_nggps_ic_batch.sh $yyyymmdd

# Move output data
echo "copying updated files to $WSICS_DIR...."
#cp -p $DATA/OUTPUT/gfs*nc $WSICS_DIR
for num in `seq 1 6`; do
  cp -p OUTPUT/gfs_data.tile${num}.nc ${WSICS_DIR}/${CDATE}.000000.fv_tracer.res.tile${num}.nc 
  status=$?
  [[ $status -ne 0 ]] && exit $status
done
touch ${WSICS_DIR}/aero_done

###############################################################
# Force Exit out cleanly
if [ ${KEEPDATA:-"NO"} = "NO" ] ; then rm -rf $DATA ; fi
#exit 0
