/*-----------------------------*/
/*      ARIMA Forecasting &    */
/*        Identification       */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/


/* Building an Autoregressive Moving Average Model */
proc arima data=Time.SimARMA plot=all;
	identify var=Y nlag=12;
	estimate p=1 q=1 method=ML;
run;
quit;

proc arima data=Time.USAirlines plot=all;
	identify var=Passengers(12) nlag=40 stationarity=(adf=5);
	*estimate p=(1,2,11,12) method=ML;
	*estimate p=(1,2,12) q=(12) method=ML;
run;
quit;


/* Automatic Model Identification */
proc arima data=Time.USAirlines plot=all;
	*identify var=Passengers(12) nlag=40 stationarity=(adf=5);
	identify var=Passengers(12) nlag=40 minic scan esacf P=(0:12) Q=(0:12);
	*estimate p=1 q=12 method=ML;
run;
quit;


/* Forecasting */
proc arima data=Time.USAirlines plot=all;
	identify var=Passengers(12) nlag=40 stationarity=(adf=5);
	estimate p=(1,2,12) q=(12) method=ML;
	forecast lead=24;
run;
quit;
