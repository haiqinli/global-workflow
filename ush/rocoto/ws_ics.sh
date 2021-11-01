USER=Judy.K.Henderson
PTMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp3/${USER}                     ## default PTMP directory
STMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp4/${USER}                     ## default STMP directory
GITDIR=/scratch2/BMC/gsd-fv3-dev/Judy.K.Henderson/test/gslv16_devops     ## where your git checkout is located
COMROT=${GITDIR}/FV3GFSrun                                               ## default COMROT directory
EXPDIR=${GITDIR}/FV3GFSwfm                                               ## default EXPDIR directory

PSLOT=ws_ics
IDATE=2020081918
EDATE=2020081918
RESDET=768

### note default RESDET=384 
###./setup_expt_fcstonly.py --pslot $PSLOT --configdir $GITDIR/parm/config --idate $IDATE --edate $EDATE --comrot $COMROT --expdir $EXPDIR [ --res $RESDET --gfs_cyc $GFS_CYC ]
### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

./setup_expt_gsd_aeroic.py --pslot $PSLOT  \
       --configdir $GITDIR/parm/config \
       --idate $IDATE --edate $EDATE \
       --comrot $COMROT --expdir $EXPDIR \
       --res $RESDET --gfs_cyc 1 

#for running chgres, forecast, and post 
./setup_workflow_aeroic.py --expdir $EXPDIR/$PSLOT --cdump gdas 
