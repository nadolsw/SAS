***/THE POWER PROCEDURE (POWER AND SAMPLE SIZE): BINOMIAL PROPORTION/***;
/*One Sample frequency*/

*EXAMPLE 1: CREDIT CARD OFFER*; 
PROC POWER;
	ONESAMPLEFREQ
	nullproportion=.1
	proportion=.2
	sides=1
	alpha=.3
	ntotal=10
	POWER=.;
RUN;

*/The POWER Procedure (ONE SAMPLE): many sample sizes of interest/*;
PROC POWER;
	ONESAMPLEFREQ
	nullproportion=.1
	proportion=.2
	sides=1
	alpha=.3
	ntotal=10 20 100
	POWER=.
;
RUN; 

*/The POWER Procedure (ONE SAMPLE): power=.8 solve for sample size/*;
*CAN'T BE COMPUTED DUE TO SAWTOOTH CURVE*;
PROC POWER;
	ONESAMPLEFREQ
	nullproportion=.1
	proportion=.2
	sides=1
	alpha=.3
	power=.80
	NTOTAL=.;
RUN; 

*/The POWER Procedure (ONE SAMPLE): Using different distributional assumptions/*;
PROC POWER;
	ONESAMPLEFREQ TEST=z METHOD=NORMAL
	nullproportion=.1
	proportion=.2
	sides=1
	alpha=.3
	power=.80
	NTOTAL=.;
RUN; 


*EXAMPLE2: BLUE JEANS*;
*ADJUSTED Z-TEST FOR DISCRETE BINOMIAL TEST*;
PROC POWER;
	ONESAMPLEFREQ test=adjz method=normal
		nullproportion=0.02
		proportion=0.04
		sides=1
		power=0.90
		alpha=0.05
		NTOTAL=.;
RUN;

*ATTEMPT TO CORRECT FOR OVERESTIMATION OF N BY PREVIOUS PROCEDURE*;
PROC POWER; 
	ONESAMPLEFREQ test=exact
		nullproportion = 0.02
		proportion=0.04
		sides=1
		alpha=0.05
		power=.
		NTOTAL=600 to 725 by 1;/*varying the sample size between 600 and 725 by 1*/
	PLOT X=N MIN=500 MAX=800 STEP=1 MARKERS=none YOPTS= (REF=0.9 CROSSREF=yes);
RUN;

PROC POWER PLOTONLY; /*get only the plot from last analysis*/
	ONESAMPLEFREQ TEST=EXACT
		nullproportion=0.02
		proportion=0.03 0.035 0.04 /*vary the proportions*/
		sides=1
		alpha=0.05
		power=.
		NTOTAL=650; /*setting sample size at 650*/
	PLOT X=N MIN=100 MAX=2500 STEP=1 MARKERS=NONE YOPTS=(REF=0.9 
			CROSSREF=YES) VARY (LINESTYLE);
RUN;

***POWER AND SAMPLE SIZE ANALYSES FOR TWO INDEPENDENT PROPORTIONS***;

/*CREDIT CARD OFFER*/
PROC POWER;
	TWOSAMPLEFREQ TEST=PCHI
		refproportion=.01
		proportiondiff=.001
		sides=1 2
		alpha=.05
		power=.8
		NTOTAL=.;
RUN;

ODS HTML STYLE=HTMLBLUECML;
PROC POWER;
	TWOSAMPLEFREQ TEST=PCHI
		refproportion=0.01
		proportiondiff=0.001
		sides=1
		alpha=0.05
		power=0.6 0.8 0.99
		groupweights= (1 1) (10 15) (1 2)
						(1 3) (1 10)
		NTOTAL=.;
	PLOT Y=POWER YOPTS=(REF=0.8 CROSSREF=YES)
		VARY(SYMBOL BY GROUPWEIGHTS);
RUN;

