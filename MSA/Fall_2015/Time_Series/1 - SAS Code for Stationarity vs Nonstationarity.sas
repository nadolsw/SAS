/*-------------------------------------*/
/*  Stationarity vs. Non-Stationarity  */
/*                                     */
/*            Dr Aric LaBarr           */
/*-------------------------------------*/

/* Linear Trend */

proc arima data=Time.Leadyear plot=all;
	identify var=Primary nlag=12 crosscorr=Time;
	estimate Input=Time;
run;
quit;


/* Quadratic Trend */

data Leadyear;
	set Time.Leadyear;
	Time2 = Time*Time;
run;

proc arima data=Leadyear plot=all;
	identify var=Primary nlag=12 crosscorr=(Time Time2);
	estimate Input=(Time Time2);
run;
quit;


/* Stochastic Trend - Differencing */

proc arima data=Time.Leadyear plot=all;
	identify var=Primary(1) nlag=12;
run;
quit;


/* Stochastic Seasons - Differencing */

proc arima data=Time.USAirlines plot=all;
	*identify var=Passengers nlag=40;
	*identify var=Passengers(12) nlag=40;
	identify var=Passengers(1 12) nlag=40;
run;
quit;


/* Augmented Dickey-Fuller Testing */

proc arima data=Time.Ebay9899 plot=all;
	*identify var=DailyHigh nlag=10 stationarity=(adf=2);
	identify var=DailyHigh(1) nlag=10 stationarity=(adf=2);
run;
quit;


/* Seasonal Augmented Dickey-Fuller Testing */

proc arima data=Time.USA_TX_NOAA plot=all;
	identify var=Temperature nlag=60 stationarity=(adf=5);
	*identify var=Temperature nlag=60 stationarity=(adf=5 dlag=12);
	*identify var=Temperature(12) stationarity=(adf=2);
run;
quit;

proc arima data=Time.USA_TX_NOAA(where=('01JAN1994'd <= Date <= '01JAN2009'd)) plot=all;
	identify var=Temperature nlag=60 stationarity=(adf=25);
	*identify var=Temperature nlag=60 stationarity=(adf=2 dlag=12);
	*identify var=Temperature(12) stationarity=(adf=2);
run;
quit;
