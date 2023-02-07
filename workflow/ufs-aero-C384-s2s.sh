USER=Kate.Zhang


BASEDIR=/scratch2/BMC/gsd-fv3-dev/lzhang/global-workflow
STMP=/scratch1/NCEPDEV/stmp2/$USER
CONFIGDIR=$BASEDIR/parm/config
IDATE=2011040100
EDATE=2011040100
APP=S2SWA
PSLOT=NP8C_C384_ATM
RES=384
GFS_CYC=1
COMROT=/scratch2/NCEPDEV/naqfc/$USER/fv3gfs/comrot
EXPDIR=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/global/$USER/fv3gfs/expdir
ICSDIR=$COMROT/$PSLOT


./setup_expt.py forecast-only --app $APP --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --res $RES --gfs_cyc $GFS_CYC --comrot $COMROT --expdir $EXPDIR --icsdir $ICSDIR


./setup_xml.py $EXPDIR/$PSLOT

