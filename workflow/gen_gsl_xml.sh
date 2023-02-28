#!/bin/sh

# check for correct number of parameters
if [ $# -lt 2 ]; then
  echo "Usage:  $0 EXPDIR PSLOT"
  exit 1
fi

EXPDIR=$1
PSLOT=$2
./setup_xml.py ${EXPDIR}/${PSLOT}

## call jobs/rocoto/makeinit_link.sh for init task
sed -i "s/init.sh/makeinit_link.sh/" $EXPDIR/$PSLOT/$PSLOT.xml
# call jobs/rocoto/arch_gsl.sh for gfsarch task
sed -i "s/arch.sh/arch_gsl.sh/" $EXPDIR/$PSLOT/$PSLOT.xml
# change task dependency to gfspost for gfsarch task
sed -i "225,235s/metp/post/"  $EXPDIR/$PSLOT/$PSLOT.xml
