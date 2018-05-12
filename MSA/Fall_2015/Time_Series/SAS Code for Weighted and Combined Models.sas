/*-----------------------------*/
/*  Weighted & Combined Models */
/*                             */
/*        Dr Aric LaBarr       */
/*-----------------------------*/


/* Building an ARIMA Model */
data USAirlines;
	set Time.USAirlines;
	if Year=2001 and Month=9 then Sep11 = 1; else Sep11 = 0;
	if Year=2002 and Month=9 then Anniv = 1; else Anniv = 0;
run; 

data USAirlines;
	set USAirlines;
	if Date > '01mar2006'd then Passengers = .;
run;

proc arima data=USAirlines plot=all;
	identify var=Passengers(12) nlag=40 stationarity=(adf=5) crosscorr=(Sep11 Anniv);
	estimate p=(1,2) q=(12) input=(/(1)Sep11 Anniv) method=ML;
	forecast lead=24 out=F_ARIMA;
run;
quit;

data MAPE_ARIMA;
	merge F_ARIMA Time.USAirlines;
	keep Forecast Passengers Date;
run;

data MAPE_ARIMA;
	set MAPE_ARIMA;
	where Date > '01mar2006'd;
	APE = abs(Passengers - Forecast)/Passengers;
run;

proc means data=MAPE_ARIMA mean;
	var APE;
run;


/* Building an ESM */
proc esm data=USAirlines print=all plot=all lead=0 outfor=F_ESM;
	id date interval=month;
	forecast Passengers / model=winters;
run;

data MAPE_ESM;
	merge F_ESM Time.USAirlines;
	keep Predict Passengers Date;
run;

data MAPE_ESM;
	set MAPE_ESM;
	where Date > '01mar2006'd;
	APE = abs(Passengers - Predict)/Passengers;
run;

proc means data=MAPE_ESM mean;
	var APE;
run;


/* Building a Neural Network Model */
data Time.LagUSAir;
	set Time.USAirlines;
	if Date > '01mar2006'd then delete;
	DiffPass = Passengers - lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(Passengers))))))))))));
	Lag1 = lag(DiffPass);
	Lag2 = lag(Lag1);
	Lag3 = lag(Lag2);
	Lag4 = lag(Lag3);
	Lag5 = lag(Lag4);
	Lag6 = lag(Lag5);
	Lag7 = lag(Lag6);
	Lag8 = lag(Lag7);
	Lag9 = lag(Lag8);
	Lag10 = lag(Lag9);
	Lag11 = lag(Lag10);
	Lag12 = lag(Lag11);
run;

proc dmdb data=Time.LagUSAir out=dmUSAir dmdbcat=catUSAir;
	var Lag1-Lag12 DiffPass Date Month;
	target DiffPass;
run;

proc neural data=Time.LagUSAir dmdbcat=catUSAir random=12345;
	hidden 2 / id=hid;
	input Lag1 Lag2 Lag12 / level=interval id=int;
	target DiffPass / level=interval id=tar;
	train outest=Parms;
	score out=Predicted;
run;

data Parms;
	set Parms;
	if _NAME_ ne "_LAST_" then delete;
run;

proc sql noprint;
	select Lag1_hid1 into :L1H1 from WORK.Parms;
	select Lag2_hid1 into :L2H1 from WORK.Parms;
	select Lag12_hid1 into :L12H1 from WORK.Parms;

	select Lag1_hid2 into :L1H2 from WORK.Parms;
	select Lag2_hid2 into :L2H2 from WORK.Parms;
	select Lag12_hid2 into :L12H2 from WORK.Parms;

	select BIAS_hid1 into :BH1 from WORK.Parms;
	select BIAS_hid2 into :BH2 from WORK.Parms;
	select hid1_DiffPass into :H1T from WORK.Parms;
	select hid2_DiffPass into :H2T from WORK.Parms;
	select BIAS_DiffPass into :BT from WORK.Parms;

	select AVG(Lag1) into :Mean_Lag1 from WORK.Predicted;
	select AVG(Lag2) into :Mean_Lag2 from WORK.Predicted;
	select AVG(Lag12) into :Mean_Lag12 from WORK.Predicted;

	select STD(Lag1) into :STD_Lag1 from WORK.Predicted;
	select STD(Lag2) into :STD_Lag2 from WORK.Predicted;
	select STD(Lag12) into :STD_Lag12 from WORK.Predicted;

quit;

data Forecast_Add;
	input Date P_DiffPass Passengers Lead;
	informat Date MONYY7.;
	format Date MONYY7.;
cards;
APR2006 . . 1
MAY2006 . . 2
JUN2006 . . 3
JUL2006 . . 4
AUG2006 . . 5
SEP2006 . . 6
OCT2006 . . 7
NOV2006 . . 8
DEC2006 . . 9
JAN2007 . . 10
FEB2007 . . 11
MAR2007 . . 12
APR2007 . . 13
MAY2007 . . 14
JUN2007 . . 15
JUL2007 . . 16
AUG2007 . . 17
SEP2007 . . 18
OCT2007 . . 19
NOV2007 . . 20
DEC2007 . . 21
JAN2008 . . 22
FEB2008 . . 23
MAR2008 . . 24
;


data Forecast;
	set Predicted (keep=Date P_DiffPass DiffPass Passengers) Forecast_Add;

	Lag1 = lag(DiffPass);
	Lag2 = lag(Lag1);
	Lag3 = lag(Lag2);
	Lag4 = lag(Lag3);
	Lag5 = lag(Lag4);
	Lag6 = lag(Lag5);
	Lag7 = lag(Lag6);
	Lag8 = lag(Lag7);
	Lag9 = lag(Lag8);
	Lag10 = lag(Lag9);
	Lag11 = lag(Lag10);
	Lag12 = lag(Lag11);
run;

proc standard data=Forecast mean=0 std=1 out=S_Forecast;
	var Lag1 Lag2 Lag12;
run;

data Forecast;
	merge Forecast S_Forecast(rename=(Lag1=S_Lag1 Lag2=S_Lag2 Lag12=S_Lag12));

	if Lead = 1 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*S_Lag1 + &L2H1*S_Lag2 + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*S_Lag1 + &L2H2*S_Lag2 + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 2 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*S_Lag2 + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*S_Lag2 + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 3 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 4 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;


data Forecast;
	set Forecast;

	if Lead = 5 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 6 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 7 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 8 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 9 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 10 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 11 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

data Forecast;
	set Forecast;

	if Lead = 12 then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*S_Lag12)) + 
					  				  &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*S_Lag12));
	LF1 = lag(Forecast);
	LF2 = lag(LF1);
	LF3 = lag(LF2);
	LF4 = lag(LF3);
	LF5 = lag(LF4);
	LF6 = lag(LF5);
	LF7 = lag(LF6);
	LF8 = lag(LF7);
	LF9 = lag(LF8);
	LF10 = lag(LF9);
	LF11 = lag(LF10);
	LF12 = lag(LF11);
run;

%macro Create(n);
	%do i = 13 %to &n;
		data Forecast;
			set Forecast;

			if Lead = &i then Forecast = &BT + &H1T*(TANH(&BH1 + &L1H1*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H1*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H1*((LF12 - &Mean_Lag12)/&STD_Lag12))) + 
					  				 		   &H2T*(TANH(&BH2 + &L1H2*((LF1 - &Mean_Lag1)/&STD_Lag1) + &L2H2*((LF2 - &Mean_Lag2)/&STD_Lag2) + &L12H2*((LF12 - &Mean_Lag12)/&STD_Lag12)));
			LF1 = lag(Forecast);
			LF2 = lag(LF1);
			LF3 = lag(LF2);
			LF4 = lag(LF3);
			LF5 = lag(LF4);
			LF6 = lag(LF5);
			LF7 = lag(LF6);
			LF8 = lag(LF7);
			LF9 = lag(LF8);
			LF10 = lag(LF9);
			LF11 = lag(LF10);
			LF12 = lag(LF11);
		run;
	%end;
%mend Create;

%Create(24)

data NN_Forecast;
	set Forecast;

	if Forecast = . then Forecast = P_DiffPass;
	keep Forecast Date Passengers NN_Forecast;
	Lag12 = lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(Passengers))))))))))));

	NN_Forecast = Lag12 + Forecast;
run;

data NN_Forecast;
	set NN_Forecast;

	keep Date NN_Forecast Passengers;
	Lag12F = lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(lag(NN_Forecast))))))))))));
	
	if NN_Forecast = . then NN_Forecast = Lag12F + Forecast;
run;

data MAPE_NN;
	merge NN_Forecast Time.USAirlines;
	keep NN_Forecast Passengers Date;
run;

data MAPE_NN;
	set MAPE_NN;
	where Date > '01mar2006'd;
	APE = abs(Passengers - NN_Forecast)/Passengers;
run;

proc means data=MAPE_NN mean;
	var APE;
run;


/* Simple Averaging of Models */
data MAPE_AVG;
	merge NN_Forecast F_ARIMA F_ESM Time.USAirlines ;
	keep Passengers Predict Forecast NN_Forecast Date Avg;
	Avg = (Predict + Forecast + NN_Forecast)/3;
run;

data MAPE_AVG;
	set MAPE_AVG;
	where Date > '01mar2006'd;
	APE = abs(Passengers - Avg)/Passengers;
run;

proc means data=MAPE_AVG mean;
	var APE;
run;


/* Weighted Combined Models - Minimum Variance */
data REG_WC;
	merge NN_Forecast F_ARIMA F_ESM;
	keep Passengers Predict Forecast NN_Forecast Date;
run;

proc reg data=REG_WC;
	model Passengers = Predict Forecast NN_Forecast / noint;
	restrict Predict = 1 - Forecast - NN_Forecast;
	output out=F_WC p=WC_Forecasts;
run;
quit;

data MAPE_WC;
	merge F_WC Time.USAirlines;
	keep Passengers WC_Forecasts Date;
run;

data MAPE_WC;
	set MAPE_WC;
	where Date > '01mar2006'd;
	APE = abs(Passengers - WC_Forecasts)/Passengers;
run;

proc means data=MAPE_WC mean;
	var APE;
run;


/* Weighted Combined Models - Adaptive Weighting */
/* Many Different Adaptive Weighting Schemes You Can Select - This is Just Example */
data REG_WCA;
	merge NN_Forecast F_ARIMA F_ESM;
	keep Passengers Predict Forecast NN_Forecast Date Weight;
	Weight = _n_**2;
run;

proc reg data=REG_WCA;
	model Passengers = Predict Forecast NN_Forecast / noint;
	restrict Predict = 1 - Forecast - NN_Forecast;
	weight Weight;
	output out=F_WCA p=WC_Forecasts;
run;
quit;

data MAPE_WCA;
	merge F_WCA Time.USAirlines;
	keep Passengers WC_Forecasts Date;
run;

data MAPE_WCA;
	set MAPE_WCA;
	where Date > '01mar2006'd;
	APE = abs(Passengers - WC_Forecasts)/Passengers;
run;

proc means data=MAPE_WCA mean;
	var APE;
run;
