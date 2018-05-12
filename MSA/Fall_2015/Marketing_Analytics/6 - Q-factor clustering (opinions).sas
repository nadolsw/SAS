libname mkt "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Marketing Analytics\Data";

data opinions;
	set mkt.opinions;
run;

title1 'Opinion Survey Results';
proc print data=work.opinions;
run;

/*check if PROC means and std dev of the items are the same.
Otherwise standardize them*/

title1 'Pre-Standardization';
proc means data=opinions mean std;
var item:;
run;

/*we request z-standardization of data*/
proc stdize data=opinions method=std out=temp;
run;

/*transpose the data- observations to columns.Each observation 
(CEO) is assigned the specified string (obs)as the prefix 
of the column name in the output matrix (qsort)*/
proc transpose data=temp prefix=obs out=qsort;
run;

/*The NOPROB option indicates that (default) Pearson’s 
correlation value will not be requited. The OUTS= option 
creates an output data set containing Spearman correlation 
coefficients (spear)*/

title1 'Spearman Correlation';
proc corr data=qsort spearman noprob nosimple nocorr outs=spear;
run;

/*Results incuding factor loadings representing fuzzy cluster 
membership, will be output (OUTSTAT=) to the results data set*/
title1 'Factor Loadings';
proc factor data=spear priors=smc method=principal scree proportion=.8 outstat=results;
var obs:;
run;

/*An ODS OUTPUT is invoked, asking that the extracted 
factor loadings be stored in dataset pattern. ORTHROFACTPAT 
is the rotated factor pattern*/

ods output orthrotfactpat=pattern;

/*The first five extracted factors are then VARIMAX-rotated 
prior to interpretation*/
title1 'Fuzzy Cluster Membership';
proc factor data=results rotate=varimax nfactors=5;
var obs:;
run;

/*The factor loadings are merged with the original dataset and
the obs no. identifying the ceo is retained in the variable ceo*/
data temp;
merge pattern opinions;
ceo = _n_;
run;

/*A simple analysis of membership in cluster 1 (factor 1)
is shown below; observations are sorted by the factor1 loadings*/
proc sort data=temp out=cluster1;
by factor1;
run;

/*The extremes of factor1, given by first and last observation 
in the sorted file, are selected. The two observations are 
retained in the data set extremes*/
data extremes;
set cluster1 end=eof;
if _n_ = 1 or eof then output;
run;

/*Responses of two CEOs at the extremes on factor1 are listed*/
title1 'Extremes (Factor 1)';
proc print data=extremes noobs;
var ceo item:;
run;
