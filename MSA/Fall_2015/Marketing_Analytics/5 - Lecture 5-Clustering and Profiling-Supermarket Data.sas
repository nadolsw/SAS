*********************CLUSTERING, PROFILING AND SCORING OF YOUR DATA***************************;
/*We will first cluster the data using both hierarchical and non-hierarchical techniques and 
then profile the data using the variables as well as use the scoring algorithm that can be
used to score new data*/

/*****Use the supermarket dataset*******/
libname super "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Marketing Analytics\Data";

data supermkt;
	set super.supermkt;
run;

%let inputs=amspent meatexp fishexp vegexp ownbrand owncar orgexp vegetarian 
hhsize nkids hrtv hrradio websurf hhincome age;

PROC STDIZE Data=supermkt METHOD=range OUT=stan;
      VAR &inputs;
RUN;

/*Hierarchical clustering using Ward's Method*/
TITLE 'Ward''s Method';
PROC CLUSTER Data=stan METHOD=Ward SIMPLE NOEIGEN CCC PSEUDO OUTTREE=tree PRINT=10;
	VAR &inputs;
RUN;

PROC TREE Data=tree OUT=treeout level=.01;
COPY &inputs;
RUN;
/*Solutions that look feasible are 2, 5 or 8 cluster solution*/
PROC TREE Data=tree n=5 OUT=treeout noprint;
COPY &inputs;
RUN;

TITLE 'CLUSTER PROFILING';
PROC MEANS Data=treeout;
	CLASS cluster;
	VAR &inputs;
RUN;

PROC FREQ Data=treeout;
	TABLES vegetarian* cluster owncar*cluster websurf*cluster/nopercent chisq;
RUN;

TITLE 'MANOVA';
PROC GLM Data=treeout;
	CLASS Cluster;
	MODEL &inputs=cluster/solution nouni;
	MANOVA h= _all_;
RUN;

/*MANOVA is requested to test differences in means*/
TITLE 'MANOVA';
PROC GLM Data=treeout;
	CLASS Cluster;
	MODEL &inputs=cluster/solution nouni;
	CONTRAST '1 vs 2' cluster 1 -1 0 0 0;
	CONTRAST '1 vs 3' cluster 1 0 -1 0 0;
	CONTRAST '1 vs 4' cluster 1 0 0 -1 0;
	CONTRAST '1 vs 5' cluster 1 0 0 0 -1;
	CONTRAST '2 vs 3' cluster 0 1 -1 0 0;
	CONTRAST '2 vs 4' cluster 0 1 0 -1 0;
	CONTRAST '2 vs 5' cluster 0 1 0 0 -1;
	CONTRAST '3 vs 4' cluster 0 0 1 -1 0;
	CONTRAST '3 vs 5' cluster 0 0 1 0 -1;
	CONTRAST '4 vs 5' cluster 0 0 0 1 -1;
	MANOVA h= _all_;
RUN;

/*To identify variables contributing to the difference, PROC ANOVA is run*/
TITLE 'ANOVA';
PROC GLM Data=treeout;
	CLASS cluster;
	MODEL &inputs=cluster;
	MEANS cluster/tukey;
RUN;

********************************************************************************************;
/*Non-Hierarchical Clustering*/
TITLE 'K-Means Clustering';
PROC FASTCLUS Data=stan REPLACE=FULL MAXC=5 LEAST=2 OUT=cluskm OUTSTAT=centroids;
     VAR &inputs;
RUN;

/*MANOVA is requested to test differences in means*/
TITLE 'MANOVA';
PROC GLM Data=cluskm;
	CLASS Cluster;
	MODEL &inputs=cluster/solution nouni;
	CONTRAST '1 vs 2' cluster 1 -1 0 0 0;
	CONTRAST '1 vs 3' cluster 1 0 -1 0 0;
	CONTRAST '1 vs 4' cluster 1 0 0 -1 0;
	CONTRAST '1 vs 5' cluster 1 0 0 0 -1;
	CONTRAST '2 vs 3' cluster 0 1 -1 0 0;
	CONTRAST '2 vs 4' cluster 0 1 0 -1 0;
	CONTRAST '2 vs 5' cluster 0 1 0 0 -1;
	CONTRAST '3 vs 4' cluster 0 0 1 -1 0;
	CONTRAST '3 vs 5' cluster 0 0 1 0 -1;
	CONTRAST '4 vs 5' cluster 0 0 0 1 -1;
	MANOVA h= _all_;
RUN;

/*To identify variables contributing to the difference, PROC ANOVA is run*/
TITLE 'ANOVA';
PROC GLM Data=cluskm;
	CLASS cluster;
	MODEL &inputs=cluster;
	MEANS cluster/tukey;
RUN;

TITLE 'Confusion Matrix by Supermarket Brand';
PROC FREQ Data=cluskm;
	TABLES supermkt*cluster/nopercent chisq;
RUN;

*********************************************************************************************;
/*Scoring New Observations -mktscore dataset n=54 observations*/

PROC STDIZE Data=mktscore METHOD=range OUT=smktscore;
	VAR &inputs;
RUN;

/*Use least=option to minimize or maximize a distance for convergence.
Use Least=2 for minimizing RMS distance between obs and cluster means; Use Least=1 for
minimizing mean absolute difference between obs and cluster median*/
PROC FASTCLUS Data=smktscore instat=centroids least=2 OUT=scored;
	var &inputs;
RUN;

/*Dataset scored will be sorted so we augment the original obs number so
an index to original observation number is retained after sorting*/
DATA Scored;
	SET Scored;
	INDEX= _N_;
RUN;

/*sort the data into ascending order by distance within cluster number-smallest distance
to the cluster appears first*/
PROC SORT Data=scored out=sortout;
	by Cluster distance;
RUN;

TITLE 'Scored Observations';
PROC PRINT Data=sortout;
	VAR index cluster distance;
RUN;

***************************************************************************************************;
/*Create short form with at least 70% predictive accuracy*/
TITLE 'DISCIMINANT ANALYSIS FOR SHORT FORM';
PROC DISCRIM Data=cluskm OUTSTAT=kstatout out=shform METHOD=normal POOL=YES LIST 
CROSSVALIDATE;
CLASS cluster;
VAR age amspent hhsize owncar websurf;
RUN;
***POOL SET TO YES IN EXAMPLE BUT SHOULD ACTUALLY BE NO OR TEST***;

****************************************************************************************************;
/*You could also start with factor analyzing your supermkt dataset and use your 
factor scores as input variables in your clustering*/
%let inputs=amspent meatexp fishexp vegexp orgexp ownbrand hhsize nkids hrtv hrradio hhincome age;

/*PROC FACTOR with Principal Axis Method option*/
PROC FACTOR DATA=stan RES MSA METHOD=P ROTATE=VARIMAX SCREE score N=6 OUT=FACTOR; 
VAR &inputs;
RUN;

TITLE 'Ward''s Method';
PROC CLUSTER Data=FACTOR METHOD=Ward PSEUDO OUTTREE=tree;
	VAR Factor1 Factor2 Factor3 Factor4 Factor5 Factor6 vegetarian websurf owncar;
	COPY &inputs;
RUN;

PROC TREE Data=tree OUT=treeout level=.01;
COPY factor1 factor2 factor3 factor4 factor5 factor6 &inputs vegetarian websurf owncar;
RUN;
/*Solutions that look feasible are 5, 6, or 7 cluster solution*/

PROC TREE Data=tree OUT=treeout NCLUSTER=6;
COPY factor1 factor2 factor3 factor4 factor5 factor6 &inputs vegetarian websurf owncar;
RUN;

TITLE 'CLUSTER PROFILING';
PROC MEANS Data=treeout;
	CLASS cluster;
	VAR &inputs factor1 factor2 factor3 factor4 factor5 factor6;
RUN;

PROC FREQ Data=treeout;
	TABLES vegetarian*cluster owncar*cluster websurf*cluster/norow nocol nopercent chisq;
RUN;

********************************************************************************************;
/*Non-Hierarchical Clustering using factor scores*/
data super.mktscore;
	set mktscore;
run;

PROC FASTCLUS Data=factor REPLACE=FULL MAXC=6 LEAST=2 OUT=cluskm OUTSTAT=centroids;
     VAR Factor1 Factor2 Factor3 Factor4 Factor5 Factor6 vegetarian websurf owncar;
RUN;

/*To identify variables contributing to the difference, PROC ANOVA is run*/
TITLE 'ANOVA';
PROC GLM Data=cluskm;
	CLASS cluster;
	MODEL &inputs=cluster;
	MEANS cluster/tukey;
RUN; quit;
