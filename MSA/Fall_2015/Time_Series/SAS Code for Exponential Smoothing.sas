/*-----------------------------*/
/*     Exponential Smoothing   */
/*            Models           */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/

/* Building a Single Exponential Smoothing Model */

proc esm data=Time.Steel print=all plot=all lead=24;
	forecast steelshp / model=simple;
run;

proc esm data=Time.Steel print=all plot=all lead=24;
	forecast steelshp / model=double;
run;

proc esm data=Time.Steel print=all plot=all lead=24;
	forecast steelshp / model=linear;
run;

proc esm data=Time.Steel print=all plot=all lead=24;
	forecast steelshp / model=damptrend;
run;



proc esm data=Time.USAirlines print=all plot=all lead=24;
	id date interval=month;
	forecast Passengers / model=simple;
run;

proc esm data=Time.USAirlines print=all plot=all lead=24;
	id date interval=month;
	forecast Passengers / model=linear;
run;

/* Building a Linear Exponential Smoothing Model */

/* Building a Seasonal Exponential Smoothing Model */

proc esm data=Time.USAirlines print=all plot=all lead=24;
	id date interval=month;
	forecast Passengers / model=seasonal;
run;

proc esm data=Time.USAirlines print=all plot=all lead=24;
	id date interval=month;
	forecast Passengers / model=multseasonal;
run;


proc esm data=Time.USAirlines print=all plot=all lead=24;
	id date interval=month;
	forecast Passengers / model=addwinters;
run;

proc esm data=Time.USAirlines print=all plot=all lead=24;
	id date interval=month;
	forecast Passengers / model=winters;
run;


proc esm data=Time.USAirlines print=all plot=all lead=24;
	id date interval=month;
	forecast Passengers / model=winters transform=log;
run;
