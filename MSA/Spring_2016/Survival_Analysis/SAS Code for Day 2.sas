/*-----------------------------*/
/*     Hazard Probabilities    */
/*         & Censoring         */
/*                             */
/*        Matthew Austin       */
/*       MSA Class of 2016     */
/*-----------------------------*/

/* Survival Curves - Censored Observations */

data Simple;
	input Customer $ Tenure censored;
datalines;
A 7 0
B 8 0
C 10 1
D 3 0
E 2 0
F 3 1
;

proc lifetest data=Simple;
	time Tenure*censored(1);
run;

proc lifetest data=Survival.Loyalty;
	time Tenure*censored(1);
	strata Loyalty;
run;

proc lifetest data=Survival.Recid;
	time Week*arrest(0);
run;


/* Hazard Probabilities - Censoring */

proc lifetest data=Simple method=life width=1 plots=h;
	time Tenure*censored(1);
run;

proc lifetest data=Survival.Loyalty method=life width=1 plots=h;
	time Tenure*censored(1);
	*strata Loyalty;
run;

proc lifetest data=Survival.Recid method=life width=1 plots=h;
	time Week*arrest(0);
run;
