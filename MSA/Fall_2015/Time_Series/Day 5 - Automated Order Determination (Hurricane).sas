proc arima data=LWFETSP.hurricanes;
	identify var=Hurricanes nlags=12
	scan p=(0:12) q=(0:12) perror=(3:12);
run;

** Demo2_02ARMAID.sas **; 

/*-------------------------------------------*
| Run the FETSP demo  LoadMacros.sas  first  | 
*-------------------------------------------*/ 

libname LWFETSP "C:\TimeSeriesData"; 
ods listing gpath = "%sysfunc(pathname(work))";
title1 "Simulated Time Series";

proc arima data=LWFETSP.armaexamples; 
   identify var=Y7 nlag=12 esacf scan minic; 
quit;

/*----  Visualizing the ESACF  ------*/

ods output ESACFPValues=work.esacfp;
proc arima data=LWFETSP.armaexamples;
   identify var=Y7 nlags=12
            esacf 
            P=(0:8) Q=(0:8) 
            PERROR=(3:12);
quit;
%VisualizeESACF(DSName=work.esacfp,OutDS=work.temp,CutOff=0.1);
proc print data=work.temp noobs;
run;
proc print data=work.esacfp noobs;
run;

/*----  Perform diagnostic checking of an ARMA(1,1) model  ----*/

proc arima data=LWFETSP.armaexamples; 
   identify var=Y7 nlag=12 noprint; 
   estimate p=1 q=1 ml; 
quit;

/*----  Consider real data: Hurricane wind speeds.  ----*/
/*----  Yearly means of storm maximum wind speeds.  ----*/

title1 "Atlantic Hurricanes";

proc arima data=LWFETSP.hurricanes; 
   identify var=meanvmax nlag=12 
            esacf scan minic
            p=(0:12) q=(0:12)
            perror = (3:12);
quit;

/*----  SCAN model=ARMA(1,1)  ----*/
proc arima data=LWFETSP.hurricanes; 
   identify var=meanvmax nlag=12 noprint;
   estimate p=1 q=1 ml;   * scan choice  *; 
quit;

/*----  Not in demo, but in course notes  ----*/

%global BestAICP BestAICQ BestSBCP BestSBCQ;
%MLMINIC(LWFETSP.hurricanes,meanvmax,12,12,OutData=work.models);

proc sort data=work.models;
   by AIC;
run;

proc print data=work.models(obs=10);
run;

%AutoARMASort(work.models,Top=6,OutDS=work.top6);

title1 ; footnote1 ; 

%DeleteDS(work.esacfp);
%DeleteDS(work.temp); 

/*--------------------------*/
/*----  End of program  ----*/
/*--------------------------*/

