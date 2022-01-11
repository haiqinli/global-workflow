#!/bin/sh 

# set machine
if [[ -d /scratch1 ]] ; then
  machine=hera
elif [[ -d /lfs4 ]] ; then
  machine=jet
else
  echo "machine not found!"
fi

# move <machine>_xml/all*xml to current directory
#     all_sites.xml, all_tasks.xml, all_defs.xml
mv ../${machine}_xml/all* ./



