libname survival "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Homework";

%let vars = backup bridgecrane servo trashrack elevation slope age;

*SET H# TO MISSING FOR ALL INSTANCES AFTER PUMP FAILS (ACCORDING TO HOUR VALUE)*;

data katrina;
	set survival.katrina;
	array h{*} h1-h48;
		do i=2 to dim(h);
			if h[i]=. then h[i]=h[i-1];
		end;
	run;

data katrina;
	set survival.katrina;
	array h{*} h1--h48;
	do i=1 to dim(h);
		if i > hour then h[i]=.;
	end;
	drop reason2 i;
run;

proc lifetest data=katrina method=life plots=all;
	time hour*survive(1);
	strata reason;
run;

*MOTOR_T INDICATES IF MOTOR WAS RUNNING AT FAILURE HOUR*;
*MOT# INDICATES WHTHER MOTOR WAS RUNNING # HOURS BEFORE FAILURE HOUR*;
*MOTOR_12 INDICATES THE NUMBER OF HOURS MOTOR WAS RUNNING IMMEDIATELY PRIOR TO FAILURE HOUR (UP TO 12)*;
data katrina;
	set katrina;
	array h{*} h1-h48;
	array mot{12};
	motor_t = h[hour];
	do i=1 to dim(mot);
		if hour > 12 then mot[i] = h[hour-i];
	end;
	motor_12 = sum(of mot1-mot12);
	if motor_12 = 12 then motor_run = 1; else motor_run = 0;
	motor_verify = mot1*mot2*mot3*mot4*mot5*mot6*mot7*mot8*mot9*mot10*mot11*mot12;
run;
*MOTOR_RUN INDICATES IF MOTOR WAS RUNNING 12 HOURS PRIOR TO FAILURE (OR CENSORING)*;
*SET MOTOR_RUN TO ZERO FOR NON-MOTOR/SURGE RELATED FAILURE (NOT CONCERNED WITH MOTOR STATUS FOR THOSE)*;


proc phreg data=katrina alpha=.03;
	model hour*reason(0,1,4) = &vars motor_run;
	output out=outres xbeta=xb resmart=mart
		resdev = dev ld=ld
		ressch = schbackup schbridgecrane schservo schtrashrack schelevation schslope schage schmotor_run
		dfbeta = dfbbackup dfbbridgecrane dfbservo dfbtrashrack dfbelevation dfbslope dfbage dfbmotor_run;
run; 
*TRASHRACK, SLOPE, AGE, SIGNIFICANT AT a=0.03*;


proc phreg data=katrina alpha=.03;
	model hour*reason(0,1,4) = &vars motor_run motor_run*hour / selection=stepwise;
	output out=outres xbeta=xb resmart=mart
		resdev = dev ld=ld
		ressch = schbackup schbridgecrane schservo schtrashrack schelevation schslope schage schmotor_run
		dfbeta = dfbbackup dfbbridgecrane dfbservo dfbtrashrack dfbelevation dfbslope dfbage dfbmotor_run;
run; 
*INCLUDE MOTOR_RUN*HOUR?*;


*AFT MODELS TO OBTAIN LOG-LIKELIHOOD RATIO VALUES & LOG-QQ PLOTS*;
proc lifereg data=katrina plots=all;
	model hour*reason(0,1,4) = TRASHRACK SLOPE AGE / alpha=.03 dist=lnormal;
run;

proc lifereg data=katrina plots=all;
	model hour*reason(0,1,4) = TRASHRACK SLOPE AGE / alpha=.03 dist=exponential;
run;

proc lifereg data=katrina plots=all;
	model hour*reason(0,1,4) = TRASHRACK SLOPE AGE / alpha=.03 dist=weibull;
run;

proc lifereg data=katrina plots=all;
	model hour*reason(0,1,4) = TRASHRACK SLOPE AGE / alpha=.03 dist=gamma maxiter=1000;
run;
*NONE OF THE DISTRIBUTIONS APPEAR TO FIR THE DATA WELL?*;

proc lifereg data=katrina plots=all;
      model hour*reason(0,1,4) = TRASHRACK SLOPE AGE / alpha=.03 dist=llogistic;
 run;



*EXAMINE OUTLIERS*;
data outres;
	set outres;
	id=_n_;
run;

proc sgplot data=outres;
	scatter x=xb y=mart / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=xb y=dev / datalabel=id;
	where dev > 3;
run;
*ID 431, 382, 572, 555 ARE OUTLIERS*;


proc sgplot data=outres;
	scatter x=hour y=schslope / datalabel=id;
run;
*ID 356, 748, 404, 403, 54, 677 ARE OUTLIERS*;

proc sgplot data=outres;
	scatter x=hour y=schmotor_run / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=hour y=schelevation / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=hour y=schage / datalabel=id;
run;
*ID 654, 647 AMONG OTHERS ARE OUTLIERS*;

proc sgplot data=outres;
	scatter x=hour y=schbackup / datalabel=id;
run;


proc sgplot data=outres;
	scatter x=hour y=ld / datalabel=id;
run;
*ID 158, 149, 13 ARE OUTLIERS*;

proc sgplot data=outres;
	scatter x=hour y=dfbbackup / datalabel=id;
run;
*ID 13, 216, 125 HAVE SIGNIFICANT INFLUENCE*;

proc sgplot data=outres;
	scatter x=hour y=dfbage / datalabel=id;
run;
*ID 433, 279 HAVE SIGNIFICANT INFLUENCE*;

proc sgplot data=outres;
	scatter x=hour y=dfbslope / datalabel=id;
run;
*ID 158, 149 HAVE SIGNIFICANT INFLUENCE*;

proc sgplot data=outres;
	scatter x=hour y=dfbelevation / datalabel=id;
run;
*ID 13 HAS SIGNIFICANT INFLUENCE*;

proc sgplot data=outres;
	scatter x=hour y=dfbmotor_run / datalabel=id;
run;
*ID 435 433 HAVE SIGNIFICANT INFLUENCE*;

data katrina_reduced;
	set katrina;
	if id in(13, 431, 382, 572, 555) then delete;
run;

