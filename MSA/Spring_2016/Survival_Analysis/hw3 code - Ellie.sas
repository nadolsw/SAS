libname hw3 "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Homework";

/*data hw3.katrina_combined;
	set hw3.katrina;
	if reason=3 then reason=2;
	if reason=4 then reason=3;
run;*/

data katrina2;
	set hw3.katrina;
	array hr(*) h1-h48;
	do i=2 to 48;
		if hr[i]=. then hr[i]=hr[i-1];
	end;
	if hour > 12 then do;
		total=0;
		do j=12 to 1 by -1;
			hours = hr[hour-j];
			total+hours;
		end;
	end;
	if total=12 then twelve=1;
	else twelve=0;
run;

data katrina2;
	set katrina2;
	array p{*} h1--h48;
	do i=1 to dim(p);
		if i > hour then p[i]=.;
	end;
	drop reason2 i;
run;

proc phreg data=katrina2;
	model hour*reason(0,1,4) = backup bridgecrane servo trashrack elevation slope age twelve;
run;

proc phreg data=katrina2;
	model hour*reason(0,1,4) = backup bridgecrane servo trashrack elevation slope age twelve twelve*hour / selection=score alpha=0.03;
run;
*trashrack age slope;
proc phreg data=katrina2;
	model hour*reason(0,1,4) = backup bridgecrane servo trashrack elevation slope age twelve / selection=forward sle=0.03;
run;
*trashrack age slope;
proc phreg data=katrina2;
	model hour*reason(0,1,4) = backup bridgecrane servo trashrack elevation slope age twelve / selection=backward sls=0.03;
run;
*final model:slope, age, trashrack;


proc phreg data=katrina2;
	model hour*reason(0,1,4) = trashrack slope age twelve;
run;

proc phreg data=katrina2;
	model hour*reason(0,1,4) = trashrack slope age;
run;


*IMPACT OF RUNNING MOTOR FOR 12 HOURS ON MOTOR/SURGE FAILURE*;
proc phreg data=katrina2;
	model hour*reason(0,1,4) = backup bridgecrane servo trashrack elevation slope age twelve		
/ selection=stepwise sls=0.03;
run;

*IMPACT OF RUNNING MOTOR FOR 12 HOURS ON FLOODING FAILURE*;
proc phreg data=katrina2;
	model hour*reason(0,2,3,4) = backup bridgecrane servo trashrack elevation slope age twelve		
/ selection=stepwise sls=0.03;
run;

proc lifereg data=katrina2 outest=Beta plots=all;
	model hour*reason(0,1,4) = twelve slope servo   / dist=gamma maxiter=10000;
run;

*IMPACT OF RUNNING MOTOR FOR 12 HOURS ON JAMMING FAILURE*;
proc phreg data=katrina2;
	model hour*reason(0,1,2,3) = backup bridgecrane servo trashrack elevation slope age twelve			
/ selection=stepwise sls=0.03;
run;



*TEST FOR TIME-VARYING COVARIATES*;
proc phreg data=katrina2;
	model hour*reason(0,1,4) = backup bridgecrane servo trashrack elevation slope age twelve
						trashrack_hour slope_hour age_hour twelve_hour
/ selection=stepwise sls=0.1;

	trashrack_hour=trashrack*hour; 
	slope_hour=slope*hour;
	age_hour=age*hour;
	twelve_hour=twelve*hour;
run;

*PLOTTING HR FOR TRASHRACH*TIME INTERACTION*;

data test;
	set katrina2 (keep=hour);
	HR=exp(-0.12110+(-0.02281*hour));
run;

proc sort data=test nodup; by hour; run;

proc sgplot data=test;
	series x=hour y=HR;
run; 


data katrina3;
	set katrina2;
	trashrack_hour=trashrack*hour;
run;

*COMPARE TO AIC OF AFT MODEL WITHOUT TRASHRACK_HOUR*;
proc lifereg data=katrina3 outest=Beta plots=all;
	model hour*reason(0,1,4) = trashrack slope age trashrack_hour / alpha=.03 dist=gamma maxiter=1000;
run;



proc phreg data=katrina2;
	model hour*reason(0,1,4) = slope age trashrack trashrack_hour;
	trashrack_hour=trashrack*hour; 
run;

proc phreg data=katrina2;
	model hour*reason(0,1,4) = backup bridgecrane servo trashrack elevation slope age twelve / selection=stepwise sls=0.03;
	output out=outres xbeta=xb resmart=mart resdev=dev ressch=schbackup schbridgecrane schservo schtrashrack schelevation schslope schage schtwelve 
	ld=ld dfbeta=dfbbackup dfbbridgecrane dfbservo dfbtrashrack dfbelevation dfbslope dfbage dftwelve; 
run;

proc lifereg data=katrina2 outest=Beta plots=all;
	model hour*reason(0,1,4) = trashrack slope age  / dist=exponential;
run;

proc lifereg data=katrina2 outest=Beta plots=all;
	model hour*reason(0,1,4) = trashrack slope age  / dist=weibull;
run;

proc lifereg data=katrina2 outest=Beta plots=all;
	model hour*reason(0,1,4) = trashrack slope age   / dist=lnormal;
run;

proc lifereg data=katrina2 outest=Beta plots=all;
	model hour*reason(0,1,4) = trashrack slope age   / dist=gamma maxiter=10000;
run;

*didn't seem to converge;

data GOF;
	Exp = -472.0717807;
	Weib = -294.7138599;
	LNorm = -384.1439656;
	GGam = -267.5469466;

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






data outres;
	set outres;
	id = _n_;
run;

proc sgplot data=outres;
	scatter x=xb y=mart / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=xb y=dev / datalabel=id;
	where dev > 3;
run;

proc sgplot data=outres;
	scatter x=hour y=schbackup / datalabel=id;
run;
proc sgplot data=outres;
	scatter x=hour y=schbridgecrane / datalabel=id;
run;
proc sgplot data=outres;
	scatter x=hour y=schservo / datalabel=id;
run;
proc sgplot data=outres;
	scatter x=hour y=schtrashrack / datalabel=id;
run;
proc sgplot data=outres;
	scatter x=hour y=schelevation / datalabel=id;
run;
proc sgplot data=outres;
	scatter x=hour y=schslope / datalabel=id;
run;
proc sgplot data=outres;
	scatter x=hour y=schage / datalabel=id;
run;
proc sgplot data=outres;
	scatter x=hour y=schtwelve / datalabel=id;
run;

      
