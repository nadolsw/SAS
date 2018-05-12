***POWER AND SAMPLE SIZE ANALYSES FOR TWO-SAMPLE t-TEST***;

*CONCRETE EXAMPLE*;

PROC POWER;
	TWOSAMPLEMEANS test=diff
		sides=2
		meandiff=400 to 500 by 50
		stddev=300 400 /*Assume Equal Variance*/
		groupweights= 1|1 to 3 by 1
		power=0.90
		alpha=0.05
		ntotal=.;
RUN;

ODS HTML STYLE=HTMLBLUECML;/*Use this ODS style for different symbols in the plot*/
PROC POWER;
	TWOSAMPLEMEANS test=diff_satt /*Satterthwaite unpooled t-test*/
		nfractional /*enables fractional input and output for sample sizes*/
		sides=2
		meandiff=400 to 500 by 50
		groupstddevs=300|350 /*Assume Unequal Variance*/
		power=0.90
		alpha=0.05
		npergroup=.;
	PLOT Y=power min=0 max=1 yopts = (ref=0.90 crossref=yes)
			vary (symbol);
RUN; 

***GENERAL LINEAR MODEL***;

***POWER AND SAMPLE SIZE ANALYSES FOR MULTIPLE LINEAR REGRESSION***;
*NOSOCOMIAL INFECTION EXAMPLE*;

/*Using partial correlation*/
ODS HTML STYLE=htmlbluecml;
PROC POWER;
	MULTREG
		model=random
		nfullpredictors=6
		ntestpredictors=1
		partialcorr=0.20 0.25 0.30
		power=0.80 0.85 0.90
		alpha=0.01
		ntotal=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.9 CROSSREF=YES) VARY (SYMBOL);
RUN;

/*Using R-square*/
PROC POWER;
	MULTREG
		model=random
		nfullpredictors=6
		ntestpredictors=3
		rsquarefull=0.80
		rsquarereduced=0.79 0.77 0.75
		power=0.80 0.85 0.90
		alpha=0.01
		ntotal=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.9 CROSSREF=YES) VARY (SYMBOL);
RUN;

*****SELF STUDY****;
***POWER AND SAMPLE SIZE ANALYSES FOR CORRELATION***;

PROC POWER;
	ONECORR dist=fisherz
		npvars=5
		corr=0.20 0.25 0.30
		nullcorr=0.10
		sides=1 
		power=0.80 0.85 0.90
		alpha=0.01
		NTOTAL=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.9 CROSSREF=YES) VARY (SYMBOL);
RUN;


***POWER AND SAMPLE SIZE ANALYSES FOR ONE-WAY ANOVA***;

*TIRE EXAMPLE*;

PROC POWER;
	ONEWAYANOVA TEST=CONTRAST
		groupmeans=2.50|2.72|2.30|2.24
		contrast= (0 1 -1 0) (.5 .5 -.5 -.5)
		stddev=0.28 0.30 0.32
		alpha=0.01
		power=0.80
		npergroup=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.8 CROSSREF=YES)
		VARY (SYMBOL BY STDDEV, PANEL BY CONTRAST);
RUN;

/*Specify the null value of the contrast to be 0.20*/

PROC POWER;
	ONEWAYANOVA TEST=CONTRAST
		groupmeans=2.50|2.72|2.30|2.24
		nullcontrast=0.20 /*specify null value of the contrast-default=0*/
		contrast= (0 1 -1 0) (.5 .5 -.5 -.5)
		stddev=0.28 0.30 0.32
		sides=1
		alpha=0.05
		power=0.80
		npergroup=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.8 CROSSREF=YES)
		VARY (SYMBOL BY STDDEV, PANEL BY CONTRAST);
RUN;

***POWER AND SAMPLE SIZE ANALYSES BY PROC GLMPOWER***;

*Tire Example*;

DATA tire;
	input brand $ wear cellwgt;
	datalines;
	A 2.50 1.2
	B 2.72 1.1
	C 2.30 1.0
	D 2.24 1.3
	;
RUN;

PROC GLMPOWER DATA=tire;
	CLASS brand;
	MODEL wear = brand;
	WEIGHT cellwgt;
	CONTRAST 'B vs C' brand 0 1 -1 0;
	CONTRAST 'Average of A&B vs. Average of C&D' brand .5 .5 -.5 -.5;
	POWER nfractional 
		stddev=0.32
		alpha=0.01
		power=0.80
		NTOTAL=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.8 CROSSREF=YES)
		VARY (SYMBOL);
RUN;

/*expanding the study by adding position and a continous variable, load_index*/

DATA tire2;
	input brand $ position $ wear;
	datalines;
	A Back 2.62
	A Front 2.38
	B Back 2.86
	B Front 2.59
	C Back 2.43
	C Front 2.21
	D Back 2.39
	D Front 2.11
	;
RUN;

PROC GLMPOWER DATA=tire2;
	CLASS brand position;
	MODEL wear = brand position;
	POWER nfractional 
		stddev=0.28
		ncovariates=1
		corrxy= 0.2 0.4 0.6
		alpha=0.01
		power=0.80
		NTOTAL=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.8 CROSSREF=YES)
		VARY (SYMBOL BY CORRXY, PANEL BY SOURCE);
RUN;

