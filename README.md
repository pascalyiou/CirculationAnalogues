# CirculationAnalogues
User Manual for AnalogSLP (v1.0, September 2014)

by Pascal Yiou, Laboratoire des Sciences du Climat et de l'Environnement, CE Saclay, l'Orme des Merisiers, 91191 Gif-sur-Yvette, France

You are reading the README file of the AnalogSLP suite of scripts to compute analogues of circulation. This suite of scripts was supported by the ERC grant "A2C2". The programs and input data files are provided "as is", with no guarantee of correct functionning. The user is warned that the author is not liable for any misuse of those programs. Please read the disclaimer document file (reproduced in English at the end of this file).

1. CONTENT
The AnalogSLP suite of programs downloads sea-level pressure (SLP) data from the NCEP reanalysis (daily field) for the North Atlantic region, then computes analogues of SLP for each day between Jan 1st 1948 and the current day.
The programme is meant to work on linux workstations.

2. INSTALLATION
The paths for routines (R scripts, shell scripts), input files and output files, have to be adapted by the user. Now, they are configured for the author's cluster. 

The R script requires ncdf library:
install.packages(c("ncdf")) should be run in R before running the programmes.
It uses the parallel library, which is distributed by default in R (>2.15).

3. RUNNING THE PROGRAMME
The general shell script "analogs_slp-genericpar.sh" launches the whole procedure in batch mode. A typical command line on a linux server could be:
> qsub -q mediump -l nodes=1:ppn=12 analogs_slp-genericpar.sh

The two operations done in analogs_slp-genericpar.sh can be executed separately.

The shell script "getNCEP_slp.sh" downloads netcdf files from the NCEP/NOAA site. It uses ncks to extract the North Atlantic region, then cdo to put longitudes in the right format.

Then the R script "NCEP_analog_SLP-generic.R" computes the analogues of SLP over the North Atlantic on the downloaded/concatenated netcdf file.

The output is a multi-column file (for instance: "slpano-NA.analog30rms.1d.all1948.dat") containing:
the date of the analyzed day (in the form yyyymmdd)
the dates of the 20 best analogues (in the form yyyymmdd)
the value of the optimized score (to determine the analogues). If rms is used, the value is minus the distance (negative numbers)
the value of the spatial correlations between the 20 analogues and the analyzed SLP.

It is up to you to exploit the information! The programme is regularly used in the BAMS report on extreme events:
Thomas C. Peterson, Peter A. Stott, Stephanie Herring, 2012: Explaining Extreme Events of 2011 from a Climate Perspective. Bull. Amer. Meteor. Soc., 93, 1041–1067. doi: http://dx.doi.org/10.1175/BAMS-D-12-00021.1 
Peterson, T. C., M. P. Hoerling, P. A. Stott and S. Herring, Eds., 2013: Explaining Extreme Events of 2012 from a Climate Perspective. Bull. Amer. Meteor. Soc.,94 (9), S1–S74.

The output file serves as input for the AnaWEGE weather generator:
Yiou, P.: AnaWEGE: a weather generator based on analogues of atmospheric circulation, Geosci. Model Dev., 7, 531-543, doi:10.5194/gmd-7-531-2014, 2014
http://www.geosci-model-dev.net/7/531/2014/gmd-7-531-2014.html

4. LEGAL ISSUES (DISCLAIMER)
This software program is protected by the intellectual property right. Its owners grant to you, free of charge, the right to use this software program exclusively for research purposes provided you clearly specify the name of the software program and the here above copyright notice in any publication, written by you, related to research results obtained and/or consolidated, in whole or in part, from the use of the software program. 
If source code of this software program has been delivered, you have to inform us of any modification of the software program by sending an email to pascal.yiou@lsce.ipsl.fr.
Any distribution of this software program is forbidden. 


For any other use, notably for any commercial use, you have to subscribe a specific license. In this case, send an email to pascal.yiou@lsce.ipsl.fr .

Liability:
The owner’s liability shall not be incurred as a result of in particular (i) loss due the Licensee's total or partial failure to fulfill its obligations, (ii) direct or consequential loss that is suffered by the Licensee due to the use or performance of the software, and (iii) more generally, any consequential loss. 

Warranty:
You acknowledge that the scientific and technical state-of-the-art when the software program was distributed did not enable all possible uses to be tested and verified, nor for the presence of possible defects to be detected. In this respect, the your attention has been drawn to the risks associated with loading, using, modifying and/or developing and reproducing the software which are reserved for experienced users.
You shall be responsible for verifying, by any or all means, the suitability of the product for your requirements, its good working order, and for ensuring that it shall not cause damage to either persons or properties.
The owners hereby represents, in good faith, that they are entitled to grant all the rights over the software program. You acknowledge that the software program is supplied "as is" by the owners without any other express or tacit warranty, other than that provided for here above and, in particular, without any warranty as to its commercial value, its secured, safe, innovative or relevant nature. Specifically, the owners do not warrant that the software program is free from any error, that it will operate without interruption, that it will be compatible with your own equipment and software configuration, nor that it will meet your requirements.
The owners do not either expressly or tacitly warrant that the
software program does not infringe any third party intellectual property right relating to a patent, software or any other property right. Therefore, the owners disclaim any and all liability towards you arising out of any or all proceedings for infringement that may be instituted in respect of the use, modification and redistribution of the software program. Nevertheless, should such proceedings be instituted against you, the owners shall provide it with technical and legal assistance for your defense. The owners disclaim any and all liability as regards your use of the name of the software program. No warranty is given as regards the existence of
prior rights over the name of the software program or as regards the existence of a trademark.
