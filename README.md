# CirculationAnalogues
Le logiciel AnalogSLP calcule des analogues de circulation atmosphérique à partir de champs de pression au niveau de la mer (sea-level pressure : SLP) de réanalyses NCEP. Le programme comporte deux phases :
1.	le chargement des données de réanalyse NCEP avec un script qui télécharge des fichiers au format netcdf, les concatène, et extrait la zone géographique d'intérêt (ici l'Atlantique Nord).
2.	Le calcul des analogues de circulation sur les données quotidiennes téléchargées.
Le calcul des analogues peut être fait en minimisant une distance euclidienne (rms), une distance de Mahalanobis, ou en maximisant une corrélation spatiale. Le calcul est fait pour chaque jour du champ de SLP. Le programme de téléchargement permet de faire l'analyse du 1/01/1948 au jour courant. Pour chaque jour, on détermine N (par exemple N=20) meilleurs analogues. En sortie, un fichier multicolonne indique les dates des N meilleurs analogues, le score (distance ou corrélation) et la corrélation spatiale. Ce fichier peut être utilisé en entrée du générateur de temps AnaWEGE.
Le calcul des analogues peut effectué en parallèle sur plusieurs processeurs (par défaut 12).
Le programme AnalogSLP a été développé en linux et macOSX. Il est composé d'un script général en shell (sh) linux, qui lance un script en shell de récupération et traitement de fichiers netcdf, et un programme en R qui calcule les analogues de circulation.
La méthodologie est décrite dans les articles :
Yiou, P.; Vautard, R.; Naveau, P. & Cassou, C. Inconsistency between atmospheric dynamics and temperatures during the exceptional 2006/2007 fall/winter and recent warming in Europe, Geophys. Res. Lett., 2007, 34, doi:10.1029/2007GL031981 
Vautard, R. & Yiou, P. Control of recent European surface climate change by atmospheric flow, Geophys. Res. Lett., 2009, 36, doi:10.1029/2009GL040480 
![image](https://user-images.githubusercontent.com/26297500/126641004-e926216a-d262-45d4-b3c9-1e5637c0bdbf.png)
