/*-----------------------------*/
/*     Accelerated Failure     */
/*          Time Model         */
/*                             */
/*        Matthew Austin       */
/*       MSA Class of 2016     */
/*-----------------------------*/

/* Accelerated Failure Time Model */

libname survival "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Data";

proc lifereg data=Survival.Loyalty;
	model Tenure*censored(1) = Income Age Loyalty / dist=lnormal;
run;

*GET LOG-LIKELIHOOD VALUES FOR EACH DISTRIBUTION*;

proc lifereg data=Survival.Recid plots=all;
	model Week*arrest(0) = fin age race wexp mar paro prio / dist=lnormal;
run;

proc lifereg data=Survival.Recid plots=all;
	model Week*arrest(0) = fin age race wexp mar paro prio / dist=exponential;
run;

proc lifereg data=Survival.Recid outest=Beta plots=all;
	model Week*arrest(0) = fin age race wexp mar paro prio / dist=weibull;
run;

proc lifereg data=Survival.Recid outest=Beta plots=all;
	model Week*arrest(0) = fin age race wexp mar paro prio / dist=gamma;
run;


/* Accelerated Failure Time Model - Weibull Distribution*/

proc lifereg data=Survival.Recid outest=Beta plots=all;
	model Week*arrest(0) = fin age race wexp mar paro prio / dist=weibull;
run;

proc lifereg data=Survival.Recid outest=Beta plots=all;
	model Week*arrest(0) = fin age prio / dist=weibull;
run;

data _null_;
	set Beta;
	call symput('b_Int', Intercept);
	call symput('sigma', _SCALE_);
	call symput('b_fin', fin);
	call symput('b_age', age);
	call symput('b_prio', prio);
run;

*TESTING THE EFFECT OF FINANCIAL AID ON TIME TO EVENT*;

data Recid2;
	set Survival.Recid;
	if fin = 1 then delete;
	Survival = exp(-(week*exp(-(&b_Int + &b_fin*fin + &b_age*age + &b_prio*prio)))**(1/&sigma));
	Old_t = (-log(Survival))**(&sigma)*exp(&b_Int + &b_fin*fin + &b_age*age + &b_prio*prio);
	New_t = (-log(Survival))**(&sigma)*exp(&b_Int + &b_fin + &b_age*age + &b_prio*prio);
	Difference = New_t - Old_t;
run;

proc means data=Recid2 mean median min max;
	var Difference;
run;


/* Goodness-of-Fit Tests to evaluate which is appropriate */

data GOF;
	Exp = -325.83;
	Weib = -319.38;
	LNorm = -322.69;
	SGam = -319.46;
	GGam = -319.38;

	LRT1 = -2*(Exp - GGam);
	LRT2 = -2*(Weib - GGam);
	LRT3 = -2*(LNorm - GGam);
	LRT4 = -2*(SGam - GGam);

	P_Value1 = 1 - probchi(LRT1,2);
	P_Value2 = 1 - probchi(LRT2,1);
	P_Value3 = 1 - probchi(LRT3,1);
	P_Value4 = 1 - probchi(LRT4,1);
run;

proc print data=GOF;
	var LRT1-LRT4 P_Value1-P_Value4;
run;


/* Graphical Evaluating Model Fit */

proc lifetest data=Survival.RECID method=life plots=(s,ls,lls) outsurv=Pred_Surv width=1;
	time week*arrest(0);
run;

data Pred_Surv;
	set Pred_Surv;
	s = survival;
	logit = log((1-s)/s);
	lnorm = probit(1-s);
	lweek = log(week);
run;

proc sgplot data=Pred_Surv;
	series y=logit x=lweek;
run;

proc sgplot data=Pred_Surv;
	series y=lnorm x=lweek;
run;
