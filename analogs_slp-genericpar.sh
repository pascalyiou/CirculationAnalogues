#!/bin/sh -l
# Calcul en temps continu d'analogues de SLP sur les reanalyses NCEP
# Pascal Yiou (LSCE)
## Version 1.0
# Se lance par:
# qsub -q mediump -l nodes=1:ppn=12 /home/users/yiou/RStat/A2C2/analogs_slp-genericpar.sh

NCPU=`wc -l < $PBS_NODEFILE`
export NCPU

start_date=`date +"%m/%d/%Y (%H:%M)"`
echo -e "\n\nStarting script at: ${start_date}\n"

cd ${HOME}/RStat/A2C2/
lwin=1
region=NA
anapred=/home/estimr1/yiou/estimr1/NOAA/hiSST.dat

## Telechargement des dernieres reanalyses:
echo -e "Downloading NCEP SLP data"
${HOME}/RStat/A2C2/getNCEP_slp.sh ${region}

## Calcul des analogues
echo -e "Computing analogues"
module load R/3.0.1
/usr/local/install/R-3.0.1/bin/R CMD BATCH "--args ${region} ${lwin}" /home/users/yiou/RStat/A2C2/NCEP_analog_SLP-generic.R /home/users/yiou/RStat/A2C2/NCEP_analog_SLP-generic.Rout

end_date=`date +"%m/%d/%Y (%H:%M)"`
echo -e "\nScript finished at: ${end_date}\n"

