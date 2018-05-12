/*-----------------------------*/
/*        Competing Risks      */
/*                             */
/*        Matthew Austin       */
/*       MSA Class of 2016     */
/*-----------------------------*/

libname survival "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Data";

/* Competing Risks - Comparing Covariates */

data const;
	set Survival.Leaders;
	event=(lost=1);
	type=1;
run;

data nat;
	set Survival.Leaders;
	event=(lost=2);
	type=2;
run;

data noncon;
	set Survival.Leaders;
	event=(lost=3);
	type=3;
run;

data Leaders2;
	set const nat noncon;
run;

proc lifetest data=Survival.Leaders2 plots=lls;
	time years*event(0);
	strata type / diff=all;
run;


/* Competing Risks with Cox Regression - Comparing Covariates */

proc phreg data=Survival.Leaders;
	class region;
	model years*lost(0) = manner start military age conflict loginc growth pop land literacy region;
run;

proc phreg data=Survival.Leaders;
	class region;
	model years*lost(0,2,3) = manner start military age conflict loginc growth pop land literacy region;
run;

proc phreg data=Survival.Leaders;
	class region;
	model years*lost(0,1,3) = manner start military age conflict loginc growth pop land literacy region;
run;

proc phreg data=Survival.Leaders;
	class region;
	model years*lost(0,1,2) = manner start military age conflict loginc growth pop land literacy region;
run;

data LRT;
	All = 3455.69;
	Const = 1482.715;
	Natural = 225.583;
	NonConst = 1593.741;

	Sum = Const + Natural + NonConst;
	Diff = All - Sum;

	P_value = 1 - probchi(Diff,26);
run;

proc print data=LRT;
run;

proc phreg data=Survival.Leaders;
	class region;
	model years*lost(0,2) = manner start military age conflict loginc growth pop land literacy region;
run;

proc phreg data=Survival.Leaders;
	class region;
	model years*lost(0,2,3) = manner start military age conflict loginc growth pop land literacy region;
run;

proc phreg data=Survival.Leaders;
	class region;
	model years*lost(0,1,2) = manner start military age conflict loginc growth pop land literacy region;
run;

data LRT2;
	Both = 3205.314;
	Const = 1482.715;
	NonConst = 1593.741;

	Sum = Const + NonConst;
	Diff = Both - Sum;

	P_value = 1 - probchi(Diff,13);
run;

proc print data=LRT2;
run;


/* Competing Risks with AFT Models */

data Survival.Leaders3;
	set Survival.Leaders;
	lower = years;
	upper = years;
	if years = 0 then do;
		lower = .;
		upper = 1;
	end;
	if lost in (0,1,2) then upper = .;
run;

proc lifereg data=Survival.Leaders3;
	class region;
	model (lower, upper) = manner start military age conflict loginc literacy region / dist=gamma;
run;

data GOF;
	Exp = -383.39;
	Weib = -372.51;
	LNorm = -377.04;
	GGam = -372.47;

	LRT1 = -2*(Exp - GGam);
	LRT2 = -2*(Weib - GGam);
	LRT3 = -2*(LNorm - GGam);

	P_Value1 = 1 - probchi(LRT1,2);
	P_Value2 = 1 - probchi(LRT2,1);
	P_Value3 = 1 - probchi(LRT3,1);
run;

proc print data=GOF;
	var LRT1-LRT3 P_Value1-P_Value3;
run;

data Survival.Leaders4;
	set Survival.Leaders;
	lower = years;
	upper = years;
	if years = 0 then do;
		lower = .;
		upper = 1;
	end;
	if lost in (0,1,3) then upper = .;
run;

proc lifereg data=Survival.Leaders4;
	class region;
	model (lower, upper) = manner start military age conflict loginc literacy region / dist=gamma;
run;

data GOF;
	Exp = -87.17;
	Weib = -82.48;
	LNorm = -83.60;
	GGam = -81.16;

	LRT1 = -2*(Exp - GGam);
	LRT2 = -2*(Weib - GGam);
	LRT3 = -2*(LNorm - GGam);

	P_Value1 = 1 - probchi(LRT1,2);
	P_Value2 = 1 - probchi(LRT2,1);
	P_Value3 = 1 - probchi(LRT3,1);
run;

proc print data=GOF;
	var LRT1-LRT3 P_Value1-P_Value3;
run;

data Survival.Leaders5;
	set Survival.Leaders;
	lower = years;
	upper = years;
	if years = 0 then do;
		lower = .;
		upper = 1;
	end;
	if lost in (0,2,3) then upper = .;
run;

proc lifereg data=Survival.Leaders5;
	class region;
	model (lower, upper) = manner start military age conflict loginc literacy region / dist=gamma;
run;

data GOF;
	Exp = -337.30;
	Weib = -336.46;
	LNorm = -338.09;
	GGam = -336.14;

	LRT1 = -2*(Exp - GGam);
	LRT2 = -2*(Weib - GGam);
	LRT3 = -2*(LNorm - GGam);

	P_Value1 = 1 - probchi(LRT1,2);
	P_Value2 = 1 - probchi(LRT2,1);
	P_Value3 = 1 - probchi(LRT3,1);
run;

proc print data=GOF;
	var LRT1-LRT3 P_Value1-P_Value3;
run;
