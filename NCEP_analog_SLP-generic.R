## Calcul d'analogues de circulation sur la SLP sur les
## reanalyses NCEP pour les USA et l'Atlantique Nord
## 
## Pascal Yiou (LSCE), Decembre 2012, modifications Janvier 2013, Juillet 2013
## Octobre 2013 (analogues a fenetres), Avril 2014, Septembre 2014, Juin 2015
## May 2017 (nom de sortie)
## Utilise le package "parallel" ditribue en standard dans les distributions
## de R
## Version 1.0
## Se lance en BATCH par:
## qsub -q mediump -l nodes=1:ppn=12 /home/users/yiou/RStat/A2C2/analogs_slp-genericpar.sh

library(ncdf) # Pour lire les fichiers netcdf d'entree
library(parallel) # Pour la parallelisation
SI=Sys.info()
if(SI[[1]] == "Darwin"){
  Rsource="/Users/pascalyiou/programmes/RStats/"
  DATdir="/Users/pascalyiou/data/"
  OUTdir=DATdir
}
if(SI[[1]] == "Linux"){
  Rsource="/home/users/yiou/RStat/"
  DATdir="/home/estimr1/yiou/estimr1/"
  OUTdir="/home/estimr1/yiou/estimr1/"
}
source(paste(Rsource,"readextranc.R",sep="")) #netcdf file functions
source(paste(Rsource,"AnalogPackage/analogfun.R",sep="")) #Analogue functions

## INITIALISATIONS des parametres d'analyse
dirname=paste(DATdir,"NCEP/",sep="")
yr.now=as.integer(format(Sys.time(), "%Y")) # Annee en cours
year.end = yr.now
## Lecture des arguments d'entree
args=(commandArgs(TRUE))
print(args)
suffana=""
if(length(args)>0){
  region=args[1]
  nfen=as.integer(args[2])
  if(length(args)>2){
    fname.nc=args[3]
  }
  if(length(args)>3){
    fname.out=args[4]
  }
  if(length(args)>4){
    lyear.ref=scan(file=args[5])
    suffana="hiSST"
  }
}else{
  region="NA"
  nfen=1
  fname.nc=paste(dirname,"slp.1948-",year.end,"_",
    region,".nc",sep="")
}

setwd(dirname)

ipara=TRUE # Parallelisation
nproc=12 # Nombre de processeurs

## PARAMETRES CHANGEABLES
prefname = "slp"
varname = "slp"
## Faut-il soustraire le cycle saisonnier?
seacycnorm=TRUE
## Taille de la demi-fenetre de calcul d'analogues (par defaut 30 jours)
nwindow=30
## Nombre d'analogues (par defaut 20)
nanalog=20
## Type de correlation (par defaut "corrnk"=par rang, "spearman"=lineaire,
## "euclid"= -distance euclidienne)
## Par defaut, on calcule tous les analogues possibles
##l.method=c("spearman","pearson","euclid")
##l.method=c("corrnk","rms","esv","mahalanobis2")
l.method=c("rms")
method="rms"
## print(paste("Calculating analogues:",year.start,"-",yr.now,
##             "nwindow=",nfen,"region=",region))

## FIN DES PARAMETRES CHANGEABLES
## Nom du fichier d'entree
##fname = paste(dirname,prefname,".",year.start,"-",year.end,"_",region,
##  ".nc",sep="")
fname=fname.nc
print(paste("Processing",fname))
nc = open.ncdf(fname)
varnc=nc$var[[varname]]
varsize=varnc$varsize
ndims=varnc$ndims
## Extraction des longitudes, latitudes et du temps
nclon=nc$dim[['lon']]
lon=nclon$vals
nclat=nc$dim[['lat']]
lat=nclat$vals
## liste des longitudes et latitude de chaque point de grille
list.lat=rep(lat,length(lon))
list.lon=rep(lon,each=length(lat))
## Traitement du temps
nctime = nc$dim[['time']]
time=nctime$vals
## Revision 20141110 a cause du changement dans NCEP de la date de reference
conv.time=caldat(time/24+julday(1,1,1800))
## Au cas ou on ne filtre pas les annees
if(!exists("lyear.ref")) lyear.ref=unique(conv.time$year)
## Choix de la saison
l.seas=list(all=1:12,SONDJF=c(8,9,10,11,12,1,2),DJF=c(1,2,12),SON=c(9:11))
seas="all"
l.mon=l.seas[[seas]]
## Lecture du fichier netcdf
yrmax=max(conv.time$year)
yrstart=conv.time$year[1]
## On prend les donnees a partir de 1948
ISEAS=which(conv.time$month %in% l.mon & conv.time$year<=yrmax)
dat=extractnc(nc,varnc,NULL,ndims,varsize)
close.ncdf(nc)

if(seacycnorm){
## Soustraction de la moyenne saisonniere jour a jour pour chaque
## point de grille
  dat.mcyc=sousseasmean(dat,conv.time)
  dat.m=dat.mcyc$anom[ISEAS,]
  zsuff="ano"
}else{
  dat.m=dat[ISEAS,]
  zsuff="raw"
}
ndat=nrow(dat.mcyc$anom)

ngri=ncol(dat.m)

##---------------------------------------------------------------------------
## Wrapper pour parallelisation
## Attention avec le 29/02 des annees bissextiles
"wrap.para" = function(ijour)
  {
    if(conv.time$day[ISEAS[ijour]]+conv.time$month[ISEAS[ijour]]*100 != 2902){
      jdiffi= which(conv.time$day[ISEAS]==conv.time$day[ISEAS[ijour]] &
        conv.time$month[ISEAS]==conv.time$month[ISEAS[ijour]] &
        conv.time$year[ISEAS]!=conv.time$year[ISEAS[ijour]] &
        conv.time$year[ISEAS] %in% lyear.ref)
    }else{
      jdiffi= which((conv.time$day[ISEAS]==29 |
        conv.time$day[ISEAS]==28) &
        conv.time$month[ISEAS]==2 &
        conv.time$year[ISEAS]!=conv.time$year[ISEAS[ijour]] &
        conv.time$year[ISEAS] %in% lyear.ref)      
    }
    kdiff=c()
## On choisit des jours calendaires proches de nwindow du jour courant    
    for(j in jdiffi) kdiff=c(kdiff,which(abs(ISEAS-j)<=nwindow))

    cor.dum=winscore(dat.m[c(ijour:(ijour+nfen-1)),],dat.m[kdiff,],
      method=method)

## Calcul de la correlation spatiale avec les meilleurs analogues    
## Correlation spatiale avec les meilleurs analogues    
    cor.test=cor(dat.m[ijour,],t(dat.m[kdiff[cor.dum$ix[1:nanalog]],]),
      method="spearman")
    
    l.iday=kdiff[cor.dum$ix[1:nanalog]]
    l.cormax=cor.dum$x[1:nanalog]
    ddijour=conv.time$day[ISEAS[ijour]]+100*conv.time$month[ISEAS[ijour]]+
      10000*conv.time$year[ISEAS[ijour]]
    ddana=conv.time$day[ISEAS[l.iday]]+
      100*conv.time$month[ISEAS[l.iday]]+
        10000*conv.time$year[ISEAS[l.iday]]
    return(c(ddijour,ddana,l.cormax,cor.test))
  }
## Fin du wrapper
##---------------------------------------------------------------------------

#rm(dat,dat.m,pc.dat)
## Calcul des analogues 
## les analogues sont choisis parmi toutes les annees sauf l'annee courante
print(paste(detectCores(),"cores detected"))
ncpus = as.numeric(Sys.getenv(c("NCPU")))
ncpus = max(nproc,ncpus,na.rm=TRUE)
print(paste("Calcul sur",ncpus,"CPUs"))

for(method in l.method){
  print(paste("Analogues with",method))
## Calcul de la matrice de covariance pour la distance de Mahalanobis
  ## ATTENTION! IL Y A DES MANIERES PLUS OPTIMALES DE CALCULER CETTE DISTANCE
  ## IL VAUT MIEUX EVITER CETTE OPTION POUR GARDER DES TEMPS DE CALCULS
  ## RAISONNABLES!
  if(method=="mahalanobis2"){
    S.dat=var(dat.mcyc$anom)
    S.dat=solve(S.dat)
  }
  
  tm=proc.time()
  Xanatestdum=mclapply(seq(1,(length(ISEAS)-nfen+1),by=1),wrap.para,
    mc.cores=ncpus)
  print(proc.time()-tm)
  Xanatest=t(matrix(unlist(Xanatestdum),nrow=(1+3*nanalog)))

  ## Sauvegarde en ASCII
  if(exists("fname.out")){
      filout = fname.out
  }else{
      filout=paste(OUTdir,"NCEP/slp",zsuff,"-",region,".analog",
                   nwindow,method,".",
                   nfen,"d.",
                   seas,yrstart,"-",yrmax,suffana,".dat",sep="")
  }
  nam=c("date",paste("date.an",1:nanalog,sep=""),
    paste("dis",1:nanalog,sep=""),
    paste("cor",1:nanalog,sep="")
    )
  write.table(file=filout,Xanatest,row.names=FALSE,col.names=nam,quote=FALSE)

}#end for method
q(save="no")
