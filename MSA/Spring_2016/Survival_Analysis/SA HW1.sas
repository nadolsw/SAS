libname survival "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Homework";

data katrina;
	set survival.katrina;
run;

proc univariate data=katrina;
run;

*EXAMINE DEGREE OF MISSINGNESS*;
proc means data=katrina n nmiss mean std min max;
run;

*PERCENTAGE OF FAILURE BY REASON*;
proc freq data=katrina;
	tables survive*reason;
run;

*HOUR VARIABLE DOES NOT ALIGN WITH H1-H48*;
*CHANGING H1-H48 TO MATCH UP WITH HOUR VARIABLE*;
data katrina;
	set katrina;
	array h{*} h1-h48;
	do i=1 to 48;
		if i <= hour then h[i]=1;
		else if i > hour then h[i]=0;
	end;
run;
*ASSUMING HOUR REPRESENTS THE LAST HOUR THE PUMP SURVIVED UNTIL*;

*CREATE CENSORED VARIABLE*;
data katrina;
	set katrina;
	if hour ne 48 then censored=1;
	else if hour=48 then censored=0;
run;

*EXAMINE AVERAGE SURVIVAL TIME BY REASON FOR FAILURE*;
proc means data=katrina;
	var hour;
	class reason;
run;

proc sgplot data=katrina; vbox hour / category=reason connect=mean; run;

*F-TEST TO SEE IF SURVIVAL TIME IS STATISTICALLY SIGNIFICANTLY DIFFERENT ACROSS LEVELS OF REASON FOR FAILURE*;
*INCLUDE LEVENE'S ONE-WAY ANOVA EQUAL VARIANCE TEST*;
proc glm data=katrina;
    class reason;
    model hour = reason;
	means reason / hovtest=levene;
run; quit;
*YES THEY ARE STATISTICALLY DIFFERENT*;

*POST-HOC PAIRWISE COMPARISON TESTS*;
proc glm data=katrina;
    class reason;
    model hour = reason;
    lsmeans reason / pdiff=all adjust=tukey;
run; quit;
*ONLY REASON 2 & 3 ARE NOT STATISTICALLY DIFFERENT*;

*SURVIVAL CURVE FOR ALL PUMPS*;
proc lifetest data=katrina method=life width=1;
	time hour*censored(0);
run;

*SURVIVAL CURVES & HAZARD RATES BY REASON FOR FAILURE*;
proc lifetest data=survival.katrina method=life width=1 plots=h outsurv=out;
	time hour*survive(1);
	strata reason / diff=all;
run;

*OUTPUT HAZARD PROBABILITY (HP)*;
data out;
	set out;
	hp=pdf/survival;
run;

proc gplot data=out;
	plot hp*hour=stratum;
run;
