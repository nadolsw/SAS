** Demo1_03GOF.sas **; 

/*-------------------------------------------*
| Run the FETSP demo  LoadMacros.sas  first  | 
*-------------------------------------------*/ 

ods listing gpath = "%sysfunc(pathname(work))";
LIBNAME LWFETSP "C:\TimeSeriesData";
title1 "AMR Daily Stock Volume";

/*----  Recalculate forecasts for AR(1), AR(4), and MA(1) models  ----*/

proc arima data=lwfetsp.amr;  
   identify var=LogVolume noprint;
   /*----  AR(1)  ----*/
   estimate p=1 method=ml noprint 
            outstat=work.Stat_AR1;
   forecast lead=12 id=Date interval=weekday 
            out=work.amr_AR1 noprint;
   /*----  MA(1)  ----*/
   estimate q=1 method=ml noprint 
            outstat=work.Stat_MA1;
   forecast lead=12 id=Date interval=weekday 
            out=work.amr_MA1 noprint;
   /*----  AR(4)  ----*/
   estimate p=4 method=ml noprint 
            outstat=work.Stat_AR4;
   forecast lead=12 id=Date interval=weekday 
            out=work.amr_AR4 noprint;
  /*----  subset model  ----*/
   estimate p=(1 5 10) method=ml noprint 
            outstat=work.Stat_subset;
   forecast lead=12 id=Date interval=weekday 
            out=work.subset noprint;
quit;

/*----  Calculate MAPE and RMSE  ----*/

data work.ar1gof;
   attrib Model length=$12
          MAPE  length=8
          NMAPE length=8
          MSE   length=8
          RMSE  length=8
          NMSE  length=8
          NumParm length=8;
   set work.amr_AR1 end=lastobs;
   retain MAPE MSE NMAPE NMSE 0 NumParm 2;
   /*----  Adjust for log transformation  ----*/
   Actual=exp(LogVolume);
   Forecast=exp(Forecast+0.5*STD*STD);
   Residual=Actual-Forecast;
   /*----  SUM and N functions necessary to handle missing  ----*/
   MAPE=sum(MAPE,100*abs(Residual)/Actual);
   NMAPE=NMAPE+N(100*abs(Residual)/Actual);
   MSE=sum(MSE,Residual**2);
   NMSE=NMSE+N(Residual);
   if (lastobs) then do;
      Model="AR(1)";
      MAPE=MAPE/NMAPE;
      RMSE=sqrt(MSE/NMSE);
      if (NumParm>0) and (NMSE>NumParm) then 
         RMSE=sqrt(MSE/(NMSE-NumParm));
      else RMSE=sqrt(MSE/NMSE);
      output;
   end;
   keep Model MAPE RMSE NumParm;
run;
proc print data=ar1gof; run; 

/*----  Since this is a routine calculation,  ----*/
/*----  turn it into a macro.                 ----*/

%macro GOFstats(ModelName=,DSName=,OutDS=,NumParms=0,
                ActualVar=Actual,ForecastVar=Forecast);
data &OutDS;
   attrib Model length=$12
          MAPE  length=8
          NMAPE length=8
          MSE   length=8
          RMSE  length=8
          NMSE  length=8
          NumParm length=8;
   set &DSName end=lastobs;
   retain MAPE MSE NMAPE NMSE 0 NumParm &NumParms;
   Residual=&ActualVar-&ForecastVar;
   /*----  SUM and N functions necessary to handle missing  ----*/
   MAPE=sum(MAPE,100*abs(Residual)/&ActualVar);
   NMAPE=NMAPE+N(100*abs(Residual)/&ActualVar);
   MSE=sum(MSE,Residual**2);
   NMSE=NMSE+N(Residual);
   if (lastobs) then do;
      Model="&ModelName";
      MAPE=MAPE/NMAPE;
      RMSE=sqrt(MSE/NMSE);
      if (NumParm>0) and (NMSE>NumParm) then 
         RMSE=sqrt(MSE/(NMSE-NumParm));
      else RMSE=sqrt(MSE/NMSE);
      output;
   end;
   keep Model MAPE RMSE NumParm;
run;
%mend GOFstats;

/*----  Before calling macro, adjust for Log scale  ----*/
data work.holdar1;
   set work.amr_AR1;
   Actual=exp(LogVolume);
   Forecast=exp(Forecast+0.5*STD*STD);
   keep Actual Forecast;
run;

%GOFstats(ModelName=AR(1),DSName=work.holdar1,OutDS=work.ar1gofm,
          NumParms=2,ActualVar=Actual,ForecastVar=Forecast);


data work.holdma1;
   set work.amr_MA1;
   Actual=exp(LogVolume);
   Forecast=exp(Forecast+0.5*STD*STD);
   keep Actual Forecast;
run;

%GOFstats(ModelName=MA(1),DSName=work.holdma1,OutDS=work.ma1gofm,NumParms=2,
          ActualVar=Actual,ForecastVar=Forecast);

data work.holdar4;
   set work.amr_AR4;
   Actual=exp(LogVolume);
   Forecast=exp(Forecast+0.5*STD*STD);
   keep Actual Forecast;
run;

%GOFstats(ModelName=AR(4),DSName=work.holdar4,OutDS=work.ar4gofm,NumParms=5,
          ActualVar=Actual,ForecastVar=Forecast);


data work.holdsubset;
   set work.subset;
   Actual=exp(LogVolume);
   Forecast=exp(Forecast+0.5*STD*STD);
   keep Actual Forecast;
run;

%GOFstats(ModelName=subset,DSName=work.holdsubset,OutDS=work.subsetgofm,NumParms=4,
          ActualVar=Actual,ForecastVar=Forecast);

data work.gof;
   set work.ar1gofm
       work.ma1gofm
       work.ar4gofm
	   work.subsetgofm;
run;

proc sort data=work.gof;
  by MAPE;
run;

title2  "Model Summary Sorted by MAPE";
proc print data=work.gof noobs;
   var Model MAPE RMSE;
   format MAPE 6.2 RMSE 9.1;
run;

/*----  Use a holdout sample (self study)  ----*/

data work.fitsample;
   set lwfetsp.amr;
   if (Date<='31DEC2010'd) then Y=LogVolume;
   else Y=.;
run;

proc arima data=work.fitsample;  
   identify var=Y noprint;
   /*----  AR(1)  ----*/
   estimate p=1 method=ml noprint 
            outstat=work.Stat_AR1;
   forecast lead=64 id=Date interval=weekday 
            out=work.amr_AR1 noprint;
   /*----  MA(1)  ----*/
   estimate q=1 method=ml noprint 
            outstat=work.Stat_MA1;
   forecast lead=64 id=Date interval=weekday 
            out=work.amr_MA1 noprint;
   /*----  AR(4)  ----*/
   estimate p=4 method=ml noprint 
            outstat=work.Stat_AR4;
   forecast lead=64 id=Date interval=weekday 
            out=work.amr_AR4 noprint;
   /*---- subset ----*/
   estimate p=(1 5 10) method=ml noprint 
            outstat=work.Stat_subset;
   forecast lead=64 id=Date interval=weekday 
            out=work.subset noprint;
quit;

data work.holdar1;
   merge work.fitsample work.amr_AR1;
   by Date;
   Actual=Volume;
   Forecast=exp(Forecast+0.5*STD*STD);
   if (Date>='01JAN2011'd) then output;
   keep Actual Forecast;
run;

%GOFstats(ModelName=AR(1),DSName=work.holdar1,OutDS=work.ar1gofm,NumParms=0,
          ActualVar=Actual,ForecastVar=Forecast);

data work.holdma1;
   merge work.fitsample work.amr_ma1;
   by Date;
   Actual=Volume;
   Forecast=exp(Forecast+0.5*STD*STD);
   if (Date>='01JAN2011'd) then output;
   keep Actual Forecast;
run;

%GOFstats(ModelName=MA(1),DSName=work.holdma1,OutDS=work.ma1gofm,NumParms=0,
          ActualVar=Actual,ForecastVar=Forecast);

data work.holdar4;
   merge work.fitsample work.amr_AR4;
   by Date;
   Actual=Volume;
   Forecast=exp(Forecast+0.5*STD*STD);
   if (Date>='01JAN2011'd) then output;
   keep Actual Forecast;
run;

%GOFstats(ModelName=AR(4),DSName=work.holdar4,OutDS=work.ar4gofm,NumParms=0,
          ActualVar=Actual,ForecastVar=Forecast);

data work.holdsubset;
   merge work.fitsample work.subset;
   by Date;
   Actual=Volume;
   Forecast=exp(Forecast+0.5*STD*STD);
   if (Date>='01JAN2011'd) then output;
   keep Actual Forecast;
run;

%GOFstats(ModelName=subset,DSName=work.holdsubset,OutDS=work.subsetgofm,NumParms=0,
          ActualVar=Actual,ForecastVar=Forecast);

data work.gof;
   set work.ar1gofm
       work.ma1gofm
       work.ar4gofm
       work.subsetgofm;
run;

proc sort data=work.gof;
  by MAPE;
run;

title2 "Model Summary Sorted by MAPE";
proc print data=work.gof noobs;
   var Model MAPE RMSE;
   format MAPE 6.2 RMSE 9.1;
run;


/*----  Clean Up  ----*/

%DeleteDS(work.gof);
%DeleteDS(work.fitsample);
%DeleteDS(work.ar1gof);
%DeleteDS(work.ar1gofm);
%DeleteDS(work.ma1gofm);
%DeleteDS(work.ar4gofm);
%DeleteDS(work.holdar1);
%DeleteDS(work.holdma1);
%DeleteDS(work.holdar4);
%DeleteDS(work.amr_AR1);
%DeleteDS(work.amr_MA1);
%DeleteDS(work.amr_AR4);
%DeleteDS(work.Stat_AR1);
%DeleteDS(work.Stat_MA1);
%DeleteDS(work.Stat_AR4);

title1 ; footnote1 ;

/*--------------------------*/
/*----  End of program  ----*/
/*--------------------------*/



