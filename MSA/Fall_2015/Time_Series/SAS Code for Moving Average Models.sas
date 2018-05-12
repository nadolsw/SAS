/*-----------------------------*/
/*     Moving Average Models   */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/

/* Building a Moving Average Model */

proc arima data=Time.SimMA1 plot=all;
	identify var=Y nlag=12;
	estimate q=1 method=ML;
run;
quit;

proc arima data=Time.AR2 plot=all;
	identify var=Y nlag=12;
	estimate q=2 method=ML;
run;
quit;

