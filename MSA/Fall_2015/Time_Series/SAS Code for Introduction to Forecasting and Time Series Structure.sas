/*-----------------------------*/
/* Introduction to Forecasting */
/*  and Time Series Structure  */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/

/* Time Series Decomposition */

proc timeseries data=Time.USAirlines plots=(series decomp) outdecomp=DECOMP;
	id date interval=month;
	var Passengers;
run;


/* White Noise Tests */

proc arima data=Time.AR2 plot(unpack)=all;
	identify var=y nlag=10;
	estimate;
run;
quit;

proc arima data=Time.AR2 plot(unpack)=all;
	identify var=y nlag=10;
	estimate p=2 method=ML;
run;
quit;
