/*One Sample frequency*/

*Direct Mail Campaign #1a for 1.1% & 1.25% response rate (one-sided)*; 
PROC POWER;
	ONESAMPLEFREQ
	nullproportion=.01
	proportion=.011 .0125
	sides=1
	ntotal=40000
	alpha=.05
	POWER=.;
RUN;

*Direct Mail Campaign #1a for 1.1% & 1.25% response rates (Two-Sided)*; 
PROC POWER;
	ONESAMPLEFREQ
	nullproportion=.01
	proportion=.011 .0125
	sides=2
	ntotal=40000
	alpha=.05
	POWER=.;
RUN;

*Perform the adjusted-z normal test to approximately identify N*;
PROC POWER;
	ONESAMPLEFREQ TEST=adjz method=normal
		nullproportion=0.01
		proportion=0.011
		sides=1
		alpha=0.05
		power=.8
		NTOTAL=.;
RUN;
*Approximately 64,171 observations required*;

PROC POWER;
	ONESAMPLEFREQ TEST=exact
		nullproportion=0.01
		proportion=0.011
		sides=1
		alpha=0.05
		power=.
		NTOTAL=64171;
RUN;
*Power is not exactly equal to 0.8*;

*Examine the range of vlaues using the exact test*;
PROC POWER;
	ONESAMPLEFREQ TEST=EXACT
		nullproportion=0.01
		proportion=0.011
		sides=1
		alpha=0.05
		power=.
		NTOTAL=60000 to 70000 by 1;
	PLOT X=N MIN=60000 MAX=70000 STEP=1000 MARKERS=none YOPTS= (REF=0.8 CROSSREF=yes);
RUN;


*Plot what sample sizes are needed to attain an 80% power rate*;
PROC POWER PLOTONLY;
	ONESAMPLEFREQ TEST=adjz method=normal
		nullproportion=0.01
		proportion=0.0125
		sides=1
		alpha=0.05
		power=.
		NTOTAL=10500 to 11500 by 1;
	PLOT X=N MIN=0 MAX=40000 STEP=1000 MARKERS=none YOPTS= (REF=0.8 CROSSREF=yes);
RUN;

*Zoom in to identify optimal sample size beyond the minimal samp size required*;
PROC POWER;
	ONESAMPLEFREQ TEST=EXACT
		nullproportion=0.01
		proportion=0.0125 /*vary the proportions*/
		sides=1
		alpha=0.05
		power=.
		NTOTAL=10800 to 11100 by 1;
	PLOT X=N MIN=10800 MAX=11100 STEP=1 MARKERS=none YOPTS= (REF=0.8 CROSSREF=yes);
RUN;

*Find the sample size for which the minimum trough is >= 0.8*;
PROC POWER;
	ONESAMPLEFREQ TEST=EXACT
		nullproportion=0.01
		proportion=0.0125 /*vary the proportions*/
		sides=1
		alpha=0.05
		power=.
		NTOTAL=10500 to 12000 by 1;
	PLOT X=N MIN=10800 MAX=12000 STEP=1 MARKERS=none YOPTS= (REF=0.8 CROSSREF=yes);
RUN;
*Corresponds to N=11,567*;

*2. Aspirin Heart Study*;
proc power;
	twosamplefreq test=pchi
		refproportion=.04 relativerisk=0.3 to 0.6 by .05
		sides=1 alpha=.01 power=.9 ntotal=.;
	PLOT Y=effect YOPTS=(REF=0.9 CROSSREF=YES);
run;





