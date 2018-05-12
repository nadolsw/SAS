********************CLUSTERING METHODS:NON-HIERARCHICAL CLUSTERING-Lecture 3**********************;
/*Clustering using PROC FASTCLUS*/
/*Use the CARSALES Dataset*/
libname MKT "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Marketing Analytics\Data";

data carsales;
	set mkt.cars;
run;

%let inputs=price engine_s horsepow wheelbas width length curb_wgt; 

/*STANDARDIZE the VARIABLES*/
PROC STDIZE data=carsales METHOD=range out=carsales; 
	VAR &inputs;
RUN;
*************************************HIERARCHICAL CLUSTERING************************;
TITLE 'CLUSTERING OF THE CARSALES DATASET';
TITLE2 'Ward Hierarchical Clustering';
PROC CLUSTER Data=carsales METHOD=Ward simple noeigen RMSSTD RSQ PSEUDO CCC OUTTREE=treecar PRINT=15;
	VAR &inputs;
	COPY manufact type;
RUN;

/*Dendrogram of cluster solution is requested*/
TITLE2 'Dendrogram of the Cluster Solution';
PROC TREE Data=treecar;
RUN;

TITLE2 'Dendrogram of the Cluster Solution';
PROC TREE Data=treecar level=.0001;
RUN;

TITLE2 'Saving 3 clusters';
PROC TREE Data=treecar NCLUSTERS=3 OUT=hcluscar NOPRINT;
COPY manufact type &inputs;
RUN;
TITLE2 'Cluscar Dataset (Partial Dataset)';
PROC PRINT Data=hcluscar (Obs=20);
RUN;

/*Cluster Profiles*/
TITLE2 'CLUSTER PROFILES-WARDS METHOD';
PROC MEANS Data=hcluscar;
	CLASS CLUSTER;
	VAR &INPUTS;
RUN;

PROC FREQ Data=hcluscar;
	TABLES type*cluster/norow nocol nopercent chisq;
RUN;


**************************************K-MEANS CLUSTERING****************************;
/*3 clusters*/
TITLE2 'K-MEANS CLUSTERING';
PROC FASTCLUS data=carsales REPLACE=FULL maxc=3 distance out=k3car;
      var &inputs;
RUN;

/*4 clusters*/
TITLE2 'K-MEANS CLUSTERING';
PROC FASTCLUS data=carsales REPLACE=FULL maxc=4 distance out=k4car;
      var &inputs;
RUN;

TITLE 'CLUSTER DEFINITIONS';
PROC FREQ Data=k3car;
Tables type*cluster/norow nocol nopercent chisq;
RUN;
