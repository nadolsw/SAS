/*-----------------------------*/
/*    Correlation Functions    */
/*       ACF, PACF, IACF       */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/

/* Correlation Functions */

proc arima data=Time.AR2 plot(unpack)=all;
	identify var=y nlag=10 outcov=Corr;
run;
quit;

proc sgplot data=Time.USAirlines;
	series x=Date y=Passengers;
	title 'United States Airlines Passengers';
run;

proc arima data=Time.USAirlines plot(unpack)=all;
	identify var=Passengers nlag=40;
run;
quit;
