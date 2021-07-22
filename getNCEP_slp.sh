#!/bin/sh
# Retrieves NCEP (SLP) reanalysis data with ncks and cdo
# Assumes that files were recovered until 2012 (only get 2013 to now)
# Concatenates the yearly files into a single file from 1948 to the current year
# Pascal Yiou, LSCE, March 2014, April 2014
# Version 1.0

varname=slp
year0=1948
year1=2013

dir=/home/estimr1/yiou/estimr1/NCEP/
cd ${dir}

yearnow=`date +"%Y"`
#region=`cat ${HOME}/RStat/A2C2/.anaparam | gawk '{print $1}'`
region=$1
lon1_0=280.0
lon2_0=50.0
lon1_1=-80.0
lon2_1=50.0
lat1=22.5
lat2=70.0

echo Retrieving $varname ${year0}-$yearnow  $region region

for ((year = ${year1}; year <= ${yearnow}; year++))
do

    fname=http://www.esrl.noaa.gov/psd/thredds/dodsC/Datasets/ncep.reanalysis.dailyavgs/surface/${varname}.${year}.nc

    echo $fname
# Recuperation du fichier sur la zone Nord Atlantique
    ncks -O -d lon,${lon1_0},${lon2_0} -d lat,${lat1},${lat2} ${fname} toto.nc 
# Remise en forme des longitudes pour avoir des longitudes ouest negatives
    cdo sellonlatbox,${lon1_1},${lon2_1},${lat1},${lat2} toto.nc ${varname}.${year}_$region.nc
done

rm toto.nc

# Concatenation
ncrcat -O slp.????_$region.nc slp.1948-${yearnow}_$region.nc
