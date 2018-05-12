libname survival "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Homework";

%let vars = backup bridgecrane servo trashrack elevation slope age;

*SURVIVAL CURVES FOR FLOODING*;
proc lifetest data=survival.katrina method=life width=1 plots=all alpha=.03;
	time hour*reason(0,2,3,4);
run;

*AFT MODELS TO OBTAIN LOG-LIKELIHOOD RATIO VALUES & LOG-QQ PLOTS*;
proc lifereg data=survival.katrina plots=all;
	model hour*reason(0,2,3,4) = &vars / alpha=.03 dist=lnormal;
	probplot ppout;
run;

proc lifereg data=survival.katrina plots=all;
	model hour*reason(0,2,3,4) = &vars / alpha=.03 dist=exponential;
	probplot ppout;
run;

proc lifereg data=survival.katrina plots=all;
	model hour*reason(0,2,3,4) = &vars / alpha=.03 dist=weibull;
	probplot ppout;
run;

proc lifereg data=survival.katrina plots=all;
	model hour*reason(0,2,3,4) = &vars / alpha=.03 dist=gamma;
	probplot ppout;
run;
*WEIBULL SEEMS MOST APPROPRIATE*;

*FORMAL DISTRIBUTIONAL ASSUMPTION TESTS*;
data GOF;
	LNorm = -375.5901836;
	Exp = -383.0887655;
	Weib = -371.6044304;
	GGam = -371.5792858;

	LRT1 = -2*(LNorm - GGam);
	LRT2 = -2*(Exp - GGam);
	LRT3 = -2*(Weib - GGam);

	P_Value1 = 1 - probchi(LRT1,1);
	P_Value2 = 1 - probchi(LRT2,2);
	P_Value3 = 1 - probchi(LRT3,1);
run;

proc print data=GOF;
	var LRT1-LRT3 P_Value1-P_Value3;
run;
*WEIBULL DISTRIBUTION IS INDEED THE BEST FIT*;

*VARIABLE REDUCTION*;
proc lifereg data=survival.katrina plots=all outest=beta;
	model hour*reason(0,2,3,4) = backup servo slope / alpha=.03 dist=weibull;
run;
*BACKUP/SERVO/SLOPE SIGNIFICANT @ 0.03*;

*CREATE DATASET CONTAINING ONLY FLOODED PUMPS*;
data flooded;
	set survival.katrina;
	if reason = 1;
run;

*CREATE LOCAL MACROS FOR PARAMETER ESTIMATES*;
data _null_;
	set beta;
	call symput('B_int', Intercept);
	call symput('Sigma', _SCALE_);
	call symput('B_backup', backup);
	call symput('B_servo', servo);
	call symput('B_slope', slope);
run;

*EXAMINE EFFECT OF ADDING SERVO UPGRADE*;
data AFT_model_servo;
	set flooded;
	if servo=0;
	Survival = exp(-(hour*exp(-(&B_int + &B_backup*backup + &B_servo*servo + &B_slope*slope)))**(1/&Sigma));
	Old_T = (-log(Survival))**(&Sigma)*exp(&B_int + &B_backup*backup + &B_servo*servo + &B_slope*slope);
	New_T_servo = (-log(Survival))**(&Sigma)*exp(&B_int + &B_backup*backup + &B_servo + &B_slope*slope);
	Difference_servo = New_T_servo - Old_T;
run;

proc means data=AFT_model n mean median min max;
	var Difference_servo;
run;

*EFFECT OF ADDING BACKUP UPGRADE*;
data AFT_model_backup;
	set flooded;
	if backup=0;
	Survival = exp(-(hour*exp(-(&B_int + &B_backup*backup + &B_servo*servo + &B_slope*slope)))**(1/&Sigma));
	Old_T = (-log(Survival))**(&Sigma)*exp(&B_int + &B_backup*backup + &B_servo*servo + &B_slope*slope);
	New_T_backup = (-log(Survival))**(&Sigma)*exp(&B_int + &B_backup + &B_servo*servo + &B_slope*slope);
	Difference_backup = New_T_backup - Old_T;
run;

proc means data=AFT_model n mean median min max;
	var Difference_backup;
run;

*SERVO APPEARS TO BE THE BETTER UPGRADE*;
