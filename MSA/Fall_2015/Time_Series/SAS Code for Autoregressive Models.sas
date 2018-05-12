/*-----------------------------*/
/*     Autoregressive Models   */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/

/* Building an Autoregressive Model */

proc arima data=Time.AR2 plot=all;
	identify var=y nlag=10;
	estimate p=2 method=ML;
run;
quit;

proc arima data=Time.USAirlines plot=all;
	identify var=Passengers nlag=40;
	*estimate p=1 method=ML maxiter=100;
	estimate p=6 method=ML maxiter=100;
	estimate p=(6) method=ML maxiter=100;
	*estimate p=(1,2,3,6) method=ML maxiter=100;
run;
quit;

