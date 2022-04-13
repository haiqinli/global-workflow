USER=Judy.K.Henderson
PTMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp3/${USER}                     ## default PTMP directory
STMP=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/stmp4/${USER}                     ## default STMP directory
GITDIR=/scratch1/BMC/gsd-fv3-dev/Judy.K.Henderson/test/gslv16_dev_cyc    ## where your git checkout is located
COMROT=${GITDIR}/FV3GFSrun                                               ## default COMROT directory
EXPDIR=${GITDIR}/FV3GFSwfm                                               ## default EXPDIR directory

PSLOT=gslnoahdevC384E40
IDATE=2020082000
EDATE=2020083000
RESDET=384
RESENS=192
NENS=40
HPSS_PROJECT=fim
START=cold
GFS_CYC=2             ## 0:  none  1: 00Z  2: 00Z,12Z  4: 00Z,06Z,12Z,18Z

### note default RESDET=384 RESENS=192 NENS=20  CCPP_SUITE=FV3_GFS_v16 START=cold GFS_CYC=1
###./setup_expt.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --comrot $COMROT --expdir $EXPDIR [ --icsdir $ICSDIR --resdet $RESDET --resens $RESENS --nens $NENS --gfs_cyc $GFS_CYC ]

python3 ./setup_expt.py cycled --pslot $PSLOT  \
       --idate $IDATE --edate $EDATE \
       --resdet=$RESDET --resens $RESENS --gfs_cyc $GFS_CYC \
       --start $START --nens $NENS --comrot $COMROT --expdir $EXPDIR

#for running chgres, forecast, and post 
./setup_workflow.py --expdir $EXPDIR/$PSLOT

