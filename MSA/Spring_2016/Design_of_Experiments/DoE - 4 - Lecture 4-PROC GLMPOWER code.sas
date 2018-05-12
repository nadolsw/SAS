******Design of Experiments: Multiple Factor Analysis******;
****PROC GLMPOWER****;


/*Example 1. Credit Card introductory and goto rate */;

/*Unbalanced sample size*/
DATA work.a;
	INPUT intro $1-4
		  goto $6-9
		  responserate
		  size; /*unbalanced sample sizes*/
	DATALINES;
LOW  LOW 	0.0135	10 
LOW  HIGH	0.0125	1	
HIGH LOW	0.0110	1	
HIGH HIGH	0.010	10
;
RUN;

PROC GLMPOWER DATA=WORK.a;
	CLASS intro goto;
	MODEL responserate=intro|goto;
	WEIGHT size;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;

/*Balanced sample sizes*/;

DATA work.b;
	INPUT intro $1-4
		  goto $6-9
		  responserate; /*balanced sample sizes*/
	DATALINES;
LOW  LOW 	0.0135
LOW  HIGH	0.0125
HIGH LOW	0.011
HIGH HIGH	0.010
;
RUN;

PROC GLMPOWER DATA=WORK.b;
	CLASS intro goto;
	MODEL responserate=intro|goto;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;

/*Departure from Design Balance and Orthogonality*/;

DATA work.c;
	INPUT intro $1-4
		  goto $6-9
		  responserate; /*balanced sample sizes*/
	DATALINES;
LOW  LOW 	0.0135
LOW  HIGH	0.0125
HIGH LOW	0.011
;
RUN;

PROC GLMPOWER DATA=WORK.c;
	CLASS intro goto;
	MODEL responserate=intro|goto;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;

/*Three factors: Adding a factor, Size of envelope*/
DATA work.d;
	INPUT intro $1-4
		  goto $6-9
		  size $11-15
		  responserate; /*balanced sample sizes*/
	DATALINES;
LOW  LOW  SMALL	0.0085
LOW  LOW  LARGE	0.0095
LOW  HIGH SMALL	0.0095
LOW  HIGH LARGE	0.0105
HIGH LOW  SMALL	0.0095
HIGH LOW  LARGE	0.0105
HIGH HIGH SMALL	0.0105
HIGH HIGH LARGE	0.0115
;
RUN;
PROC PRINT Data=work.d;
RUN; 

PROC GLMPOWER Data=work.d;
	CLASS intro goto size;
	MODEL responserate=intro|goto|size;
	POWER
		power=0.80
		stddev=%sysfunc(sqrt(0.01*0.99))
		NTOTAL=.;
RUN;

/*Example 2. Tire Study */;

DATA tire1;
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

ODS HTML STYLE=HTMLBLUECML; 
PROC GLMPOWER DATA=tire1;
	CLASS brand position;
	MODEL wear = brand position;
	POWER nfractional 
		stddev=0.28
		ncovariates=1
		corrxy= 0.2 0.4 0.6
		alpha=0.01
		power=0.80
		NTOTAL=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.8	CROSSREF=YES)
	VARY (SYMBOL BY CORRXY, PANEL BY SOURCE);
RUN;

/*Specification with Contrasts*/

PROC GLMPOWER DATA=tire1;
	CLASS brand position;
	MODEL wear = brand position;
	CONTRAST 'B vs. C' brand 0 1 -1 0;
	CONTRAST 'Average A&B vs. Average C&D' brand .5 .5 			-.5 -.5; 
	POWER nfractional 
		stddev=0.28
		ncovariates=1
		corrxy= 0.2 0.4 0.6
		alpha=0.01
		power=0.80
		effects=()
		NTOTAL=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.8 CROSSREF=YES) 
	VARY (SYMBOL BY CORRXY, PANEL BY SOURCE);
RUN;

/*Specification with Contrasts and Interaction*/;

PROC GLMPOWER DATA=tire1;
	CLASS brand position;
	MODEL wear = brand|position;
	CONTRAST 'Avg A&B Back vs Avg C&D Back' 
	brand 0.5 0.5 -0.5 -0.5
	brand*position 0.5 0 0.5 0 -0.5 0 -0.5 0;
	CONTRAST 'Avg A&B Front vs Avg C&D Front' 
	brand 0.5 0.5 -0.5 -0.5
	brand*position 0 0.5 0 0.5 0 -0.5 0 -0.5;
	POWER nfractional 
		stddev=0.28
		ncovariates=1
		corrxy= 0.2 0.4 0.6
		alpha=0.01
		power=0.80
		effects=()
		NTOTAL=.;
	PLOT Y=POWER MIN=0 MAX=1 YOPTS=(REF=0.8 CROSSREF=YES)
		VARY (SYMBOL BY CORRXY, PANEL BY SOURCE);
RUN;
