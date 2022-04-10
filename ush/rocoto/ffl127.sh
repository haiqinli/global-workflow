USER=Judy.K.Henderson
GITDIR=/scratch1/BMC/gsd-fv3-dev/Judy.K.Henderson/test/gslv16_rtdev1          ## where your git checkout is located
COMROT=$GITDIR/FV3GFSrun                                         ## default COMROT directory
EXPDIR=$GITDIR/FV3GFSwfm                                         ## default EXPDIR directory
#JKHICSDIR=/scratch1/BMC/gsd-fv3/rtruns/FV3ICS_L127/
ICSDIR=$COMROT/FV3ICS_L127/

PSLOT=ff_l127
IDATE=2022040600
EDATE=2022040600
RESDET=768               ## 96 192 384 768

### gfs_cyc 1  00Z only;  gfs_cyc 2  00Z and 12Z

python3 ./setup_expt.py forecast-only --pslot $PSLOT  --gfs_cyc 1 \
       --idate $IDATE --edate $EDATE --resdet $RESDET \
       --comrot $COMROT --expdir $EXPDIR --icsdir $ICSDIR

./setup_workflow_fcstonly_gsl_ics.py --expdir $EXPDIR/$PSLOT

## call jobs/rocoto/makeinit_link.sh for init task
###sed -i "s/init.sh/makeinit_link.sh/" $EXPDIR/$PSLOT/$PSLOT.xml
# call jobs/rocoto/getic_gsl.sh for gfsgetic task
sed -i "s/getic.sh/getic_gsl_fv3gfsv16.sh/" $EXPDIR/$PSLOT/$PSLOT.xml
# call jobs/rocoto/arch_gsl.sh for gfsarch task
sed -i "s/arch.sh/arch_gsl.sh/" $EXPDIR/$PSLOT/$PSLOT.xml


