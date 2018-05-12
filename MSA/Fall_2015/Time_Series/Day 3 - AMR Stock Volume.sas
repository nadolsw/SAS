** Demo1_02ACF.sas **;
ods listing gpath = "%sysfunc(pathname(work))";
LIBNAME LWFETSP "C:\TimeSeriesData";
Title "AMR corporation";  
proc print data=LWFETSP.amr(obs=40); run; 

ods graphics on; 
/*----  Produce Diagnostics  ----*/
proc arima data=lwfetsp.amr plots=all;
   identify var=LogVolume nlags=15;
quit;

/*----  Produce large versions of plots  ----*/

proc arima data=lwfetsp.amr plots=all plots(unpack);
   identify var=LogVolume nlags=15
            outcov=LWFETSP.amrcov;
quit;

/*----  Fit an AR(1) Model  ----*/
/* Y(t)-mu = a(Y(t-1)-mu) + e(t) */

proc arima data=LWFETSP.amr;
   identify var=LogVolume nlags=15 noprint;
   estimate p=1 ml;
quit;

/*----  Fit an MA(1) Model  ----*/
/*    Y(t)-mu = e(t)-b e(t-1)   */

proc arima data=LWFETSP.amr;
   identify var=LogVolume nlags=15 noprint;
   estimate q=1 ml;
quit;

/*----  Residuals of AR(1) model are not white noise.  ----*/
/*----  Refine the model by adding additional terms.   ----*/

proc arima data=LWFETSP.amr;
   identify var=LogVolume nlags=15 noprint;
   estimate p=4 ml;
quit;

/*----  AR(4) model seems adequate. Generate forecasts  ---*/

proc arima data=LWFETSP.amr plots(only)=(forecast(forecast));
   identify var=LogVolume nlags=15 noprint;
   estimate p=4 ml noprint;
   forecast lead=15 id=Date interval=weekday;
quit;

/*---- Stock market open 5 days per week. 
       Try subset model using p=(laglist) --*/

proc arima data=LWFETSP.amr 
   plots(only)=(forecast(forecast));
   identify var=LogVolume nlags=15 noprint;
   estimate p=(1 5 10) ml;
   forecast lead=15 id=Date interval=weekday;
quit;


/*--------------------------*/
/*----  End of program  ----*/
/*--------------------------*/



