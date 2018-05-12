/*-----------------------------*/
/*        Seasonal Models      */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/

/* Building a Model with Seasonal Dummy Variables */

proc arima data=Time.Constr plot=series(corr);
	identify var=contrcts nlag=30;
run;
quit; 


data Time.Constr;
	set Time.Constr;
	Month = MONTH(Date);
	if month=1 then Jan = 1; else Jan=0;
	if month=2 then Feb = 1; else Feb=0;
	if month=3 then Mar = 1; else Mar=0;
	if month=4 then Apr = 1; else Apr=0;
	if month=5 then May = 1; else May=0;
	if month=6 then Jun = 1; else Jun=0;
	if month=7 then Jul = 1; else Jul=0;
	if month=8 then Aug = 1; else Aug=0;
	if month=9 then Sep = 1; else Sep=0;
	if month=10 then Oct = 1; else Oct=0;
	if month=11 then Nov = 1; else Nov=0;
	if month=12 then Dec = 1; else Dec=0;
run;


data Time.Constr2;
	set Time.Constr;
	
	Month2 = mod(_n_,12);
	if Month2=0 then Month2=12;
	
	if month2=1 then Jan = 1; else Jan=0;
	if month2=2 then Feb = 1; else Feb=0;
	if month2=3 then Mar = 1; else Mar=0;
	if month2=4 then Apr = 1; else Apr=0;
	if month2=5 then May = 1; else May=0;
	if month2=6 then Jun = 1; else Jun=0;
	if month2=7 then Jul = 1; else Jul=0;
	if month2=8 then Aug = 1; else Aug=0;
	if month2=9 then Sep = 1; else Sep=0;
	if month2=10 then Oct = 1; else Oct=0;
	if month2=11 then Nov = 1; else Nov=0;
	if month2=12 then Dec = 1; else Dec=0;
run;


proc reg data=Time.Constr plot=diagnostics;
	model contrcts = JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV;
run;
quit;


proc arima data=Time.Constr plot=series(corr);
	identify var=contrcts nlag=30 crosscorr=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV);
	estimate input=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV);
run;
quit; 


/* Forecasting with Seasonal Dummy Variables */

data Time.Constr2;
	input Date Contrcts Intrate Hstarts Month;
	informat Date MONYY5.;
	format Date MONYY5.;
cards;
NOV89 . . . 11
DEC89 . . . 12
JAN90 . . . 1
FEB90 . . . 2
MAR90 . . . 3
APR90 . . . 4
MAY90 . . . 5
JUN90 . . . 6
JUL90 . . . 7
AUG90 . . . 8
SEP90 . . . 9
OCT90 . . . 10
NOV90 . . . 11
DEC90 . . . 12
JAN91 . . . 1
FEB91 . . . 2
MAR91 . . . 3
APR91 . . . 4
MAY91 . . . 5
JUN91 . . . 6
JUL91 . . . 7
AUG91 . . . 8
SEP91 . . . 9
OCT91 . . . 10
;


data Time.Constr2;
	set Time.Constr2;
	if month=1 then Jan = 1; else Jan=0;
	if month=2 then Feb = 1; else Feb=0;
	if month=3 then Mar = 1; else Mar=0;
	if month=4 then Apr = 1; else Apr=0;
	if month=5 then May = 1; else May=0;
	if month=6 then Jun = 1; else Jun=0;
	if month=7 then Jul = 1; else Jul=0;
	if month=8 then Aug = 1; else Aug=0;
	if month=9 then Sep = 1; else Sep=0;
	if month=10 then Oct = 1; else Oct=0;
	if month=11 then Nov = 1; else Nov=0;
	if month=12 then Dec = 1; else Dec=0;
run;


data Time.Constr3;
	set Time.Constr Time.Constr2;
run;

 
proc arima data=Time.Constr3 plot=forecasts(all);
	identify var=contrcts nlag=30 crosscorr=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV);
	estimate input=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV);
	forecast lead=24;
run;
quit;


/* Forecasting with Seasonal Dummy Variables AND Trend*/

proc arima data=Time.Constr3 plot=forecasts(all);
	identify var=contrcts nlag=30 crosscorr=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV Date);
	estimate input=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV Date);
	forecast lead=24;
run;
quit;
 

data Time.Constr3;
	set Time.Constr3;
	Date2=Date**2;
run;


proc arima data=Time.Constr3 plot=forecasts(all);
	identify var=contrcts nlag=30 crosscorr=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV Date Date2);
	estimate input=(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT Date Date2);
	forecast lead=24;
run;
quit;
 



/* Building a Seasonal ARIMA Model */

proc arima data=Time.USA_TX_NOAA(where=('01JAN1994'd <= Date <= '01JAN2009'd)) plot=all;
	*identify var=Temperature nlag=60 stationarity=(adf=5);
	*identify var=Temperature nlag=60 stationarity=(adf=5 dlag=12);
	identify var=Temperature(12) stationarity=(adf=5);
	estimate p=1 q=(12) method=ml;
run;
quit;



/* Multiplicative vs. Additive */

proc arima data=Time.USA_TX_NOAA(where=('01JAN1994'd <= Date <= '01JAN2009'd)) plot=all;
	identify var=Temperature nlag=60 stationarity=(adf=5);
	identify var=Temperature nlag=60 stationarity=(adf=2 dlag=12);
	identify var=Temperature(12) stationarity=(adf=2);
	estimate q=(1,12,13);
	estimate q=(1,2)(12);
run;
quit;
 

/* Building a Model with Trigonometric Functions */

proc arima data=Time.Constr plot=series(corr);
	identify var=contrcts nlag=30;
run;
quit;


data Time.Constr_Trig;
	set Time.Constr3;
	pi = constant('PI');
	x1=cos(2*pi*1*_n_/12); x2=sin(2*pi*1*_n_/12);
	x3=cos(2*pi*2*_n_/12); x4=sin(2*pi*2*_n_/12);
	x5=cos(2*pi*3*_n_/12); x6=sin(2*pi*3*_n_/12);
	x7=cos(2*pi*4*_n_/12); x8=sin(2*pi*4*_n_/12);
	x9=cos(2*pi*5*_n_/12); x10=sin(2*pi*5*_n_/12);
run;


proc arima data=Time.Constr_Trig plot=forecasts(all);
	identify var=contrcts nlag=30 crosscorr=(x1 x2 x3 x4 x5 x6 x7 x8 x9 x10);
	estimate input=(x1 x2 x3 x4 x5 x6 x7 x8 x9 x10);
	estimate input=(x1 x2 x4 x10);
	forecast lead=24;
run;
quit;
 

proc arima data=Time.Constr_Trig plot=forecasts(all);
	identify var=contrcts nlag=30 crosscorr=(x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 Date Date2);
	estimate input=(x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 Date Date2);
	estimate input=(x1 x2 x3 x4 x7 x10 Date Date2);
	forecast lead=24;
run;
quit;
