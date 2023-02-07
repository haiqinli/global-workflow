USER=Kate.Zhang


APP=ATM
BASEDIR=/scratch2/BMC/gsd-fv3-dev/lzhang/global-workflow
STMP=/scratch1/NCEPDEV/stmp2/$USER
CONFIGDIR=$BASEDIR/parm/config
IDATE=2016071500
EDATE=2016071500
APP=ATMA
PSLOT=NP8C_C96_ATM
RES=96
GFS_CYC=1
COMROT=/scratch2/NCEPDEV/naqfc/$USER/fv3gfs/comrot
EXPDIR=/scratch2/BMC/gsd-fv3-dev/NCEPDEV/global/$USER/fv3gfs/expdir
ICSDIR=$COMROT/$PSLOT


./setup_expt.py forecast-only --app $APP --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --res $RES --gfs_cyc $GFS_CYC --comrot $COMROT --expdir $EXPDIR --icsdir $ICSDIR


./setup_xml.py $EXPDIR/$PSLOT

