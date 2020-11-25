#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
export dir=` pwd `

cd ./prepchem_NC.fd/process-obs/FV3/gbbepx2netcdf/

echo " Building ... prepchem to convert binary to NetCDF"

sh mk-hera.sh