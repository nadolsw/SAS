/*Five stocks with the best LM at Lag 1*/
/* TRV  JPM  VZ  XOM  KO */

/*************************TRV*********************************/

/* Load Needed Macros */
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\download.sas";
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\get_stocks.sas";

/* Get a Dataset with the Dow Jones Industrial Average (TRV) */
%let stocks = TRV;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01Mar2006,29Feb2016,keepPrice=1);

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data Stocks;
  set Stocks;
  format Date date7.;
run; 

/* Add 30 Observations for Forecasting at End of Series */
data Stocks(drop=i);
  set Stocks end = eof;
  output;
  if eof then do i=1 to 30;
    date=date+i;
    TRV_p=.;
	TRV_r=.;
    output;
  end;
run;

/* Plot the Price Data */
proc sgplot data=Stocks;
  title "TRV: Price";
  series x=date y=TRV_p;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Plot the Returns Data */
proc sgplot data=Stocks;
  title "TRV: Log Returns";
  series x=date y=TRV_r;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Fit Kernel Density-estimation on Log Returns*/
*looking at distribution of returns;
*tails are wide and slightly skewed right;
proc sgplot data=Stocks;
  title "TRV: Log Returns Kernel Density";
  density TRV_r / type=kernel;
  keylegend / location=inside position=topright;
run;

/* Test for GARCH Effects and Normality */
proc autoreg data=Stocks all plots(unpack);
  model TRV_r =/ archtest normal ; /*normal will test if volatility is normal*/
run;

/* Estimate Different GARCH Models */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   *garch_n:   model TRV_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   *garch_t:   model TRV_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   *qgarch:    model TRV_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
	qgarch_t:  model TRV_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   *garch_m:   model TRV_r = / garch=(p=1, q=1, mean=linear) method=ml;
   							output out=garch_m ht=predicted_var;
   *ewma:      model TRV_r = /noint garch=(p=1, q=1, type=integ,noint) method=ml BDS=(Z=SR , D=2.0);
                            output out=ewma ht=predicted_var;
   *egarch:    model TRV_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
run;
*ignore the first bit of output bc it deals with the mean, which we are not looking at here
just make sure the model converges;
*look at AIC SBC to compare models;
*ARCH1 & GARCH1 effects are your alphas and betas
--the ARCH tells us how badly a shock will affect the company (closer to 1 is worse)
--the closer the GARCH1 is to 1 the longer the company will be bothered by a shock;


/* Prepare Data for Plotting the Results */
data all_results;
  set garch_n(in=a) garch_t(in=b) egarch(in=c) qgarch_t(in=d) garch_m(in=e) ewma(in=f);
  format model $20.;
  if a then model="GARCH: Normal";
  if b then model="GARCH: T dist";
  else if c then model="Exp. GARCH";
  else if d then model="Quad. GARCH: T dist";
  else if e then model="GARCH Mean";
  else if f then model="EWMA";
run;

proc sort data=all_results;
  by model;
run;

/* Plot the Different Model Forecasts */
title;
proc gplot data=all_results /*(where=(date ge '01JAN2013'd))*/;
  plot (predicted_var)*date = model/ legend=legend1;
  plot TRV_r*date / legend=legend1;
  symbol1 i=join c=blue      w=2 v=none;
  symbol2 i=join c=green     w=2 v=none;
  symbol3 i=join c=red       w=2 v=none;
  symbol4 i=join c=magenta   w=2 v=none;
  symbol5 i=join c=black     w=2 v=none;
  symbol6 i=none c=purple    w=1 v=dot;
run;
quit;

/* Extract AIC, SBC and LIK measures */
data sbc_aic_lik;
   set fitsum_all_garch_models;
   keep Model SBC AIC Likelihood;
   if upcase(Label1)="SBC" then do; SBC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="SBC" then do; SBC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="AIC" then do; AIC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="AIC" then do; AIC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="LOG LIKELIHOOD" then do; Likelihood=input(cValue1,BEST12.4); end;
   if upcase(Label2)="LOG LIKELIHOOD" then do; Likelihood=input(cValue2,BEST12.4); end;
   if not ((SBC=.) and (Likelihood=.)) then output;
run;



/*************************JPM*********************************/

/* Load Needed Macros */
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\download.sas";
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\get_stocks.sas";

/* Get a Dataset with the Dow Jones Industrial Average (JPM) */
%let stocks = JPM;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01Mar2006,29Feb2016,keepPrice=1);

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data Stocks;
  set Stocks;
  format Date date7.;
run; 

/* Add 30 Observations for Forecasting at End of Series */
data Stocks(drop=i);
  set Stocks end = eof;
  output;
  if eof then do i=1 to 30;
    date=date+i;
    JPM_p=.;
	JPM_r=.;
    output;
  end;
run;

/* Plot the Price Data */
proc sgplot data=Stocks;
  title "JPM: Price";
  series x=date y=JPM_p;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Plot the Returns Data */
proc sgplot data=Stocks;
  title "JPM: Log Returns";
  series x=date y=JPM_r;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Fit Kernel Density-estimation on Log Returns*/
*looking at distribution of returns;
*tails are wide and slightly skewed right;
proc sgplot data=Stocks;
  title "JPM: Log Returns Kernel Density";
  density JPM_r / type=kernel;
  keylegend / location=inside position=topright;
run;

/* Test for GARCH Effects and Normality */
proc autoreg data=Stocks all plots(unpack);
  model JPM_r =/ archtest normal ; /*normal will test if volatility is normal*/
run;

/* Estimate Different GARCH Models */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   *garch_n:   model JPM_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   *garch_t:   model JPM_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   qgarch:    model JPM_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
	qgarch_t:  model JPM_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   *garch_m:   model JPM_r = / garch=(p=1, q=1, mean=linear) method=ml;
   							output out=garch_m ht=predicted_var;
   *ewma:      model JPM_r = /noint garch=(p=1, q=1, type=integ,noint) method=ml BDS=(Z=SR , D=2.0);
                            output out=ewma ht=predicted_var;
   *egarch:    model JPM_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
run;
*ignore the first bit of output bc it deals with the mean, which we are not looking at here
just make sure the model converges;
*look at AIC SBC to compare models;
*ARCH1 & GARCH1 effects are your alphas and betas
--the ARCH tells us how badly a shock will affect the company (closer to 1 is worse)
--the closer the GARCH1 is to 1 the longer the company will be bothered by a shock;


/* Prepare Data for Plotting the Results */
data all_results;
  set garch_n(in=a) garch_t(in=b) egarch(in=c) qgarch_t(in=d) garch_m(in=e) ewma(in=f);
  format model $20.;
  if a then model="GARCH: Normal";
  if b then model="GARCH: T dist";
  else if c then model="Exp. GARCH";
  else if d then model="Quad. GARCH: T dist";
  else if e then model="GARCH Mean";
  else if f then model="EWMA";
run;

proc sort data=all_results;
  by model;
run;

/* Plot the Different Model Forecasts */
title;
proc gplot data=all_results /*(where=(date ge '01JAN2013'd))*/;
  plot (predicted_var)*date = model/ legend=legend1;
  plot JPM_r*date / legend=legend1;
  symbol1 i=join c=blue      w=2 v=none;
  symbol2 i=join c=green     w=2 v=none;
  symbol3 i=join c=red       w=2 v=none;
  symbol4 i=join c=magenta   w=2 v=none;
  symbol5 i=join c=black     w=2 v=none;
  symbol6 i=none c=purple    w=1 v=dot;
run;
quit;

/* Extract AIC, SBC and LIK measures */
data sbc_aic_lik;
   set fitsum_all_garch_models;
   keep Model SBC AIC Likelihood;
   if upcase(Label1)="SBC" then do; SBC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="SBC" then do; SBC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="AIC" then do; AIC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="AIC" then do; AIC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="LOG LIKELIHOOD" then do; Likelihood=input(cValue1,BEST12.4); end;
   if upcase(Label2)="LOG LIKELIHOOD" then do; Likelihood=input(cValue2,BEST12.4); end;
   if not ((SBC=.) and (Likelihood=.)) then output;
run;


/*************************VZ*********************************/

/* Load Needed Macros */
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\download.sas";
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\get_stocks.sas";

/* Get a Dataset with the Dow Jones Industrial Average (VZ) */
%let stocks = VZ;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01Mar2006,29Feb2016,keepPrice=1);

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data Stocks;
  set Stocks;
  format Date date7.;
run; 

/* Add 30 Observations for Forecasting at End of Series */
data Stocks(drop=i);
  set Stocks end = eof;
  output;
  if eof then do i=1 to 30;
    date=date+i;
    VZ_p=.;
	VZ_r=.;
    output;
  end;
run;

/* Plot the Price Data */
proc sgplot data=Stocks;
  title "VZ: Price";
  series x=date y=VZ_p;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Plot the Returns Data */
proc sgplot data=Stocks;
  title "VZ: Log Returns";
  series x=date y=VZ_r;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Fit Kernel Density-estimation on Log Returns*/
*looking at distribution of returns;
*tails are wide and slightly skewed right;
proc sgplot data=Stocks;
  title "VZ: Log Returns Kernel Density";
  density VZ_r / type=kernel;
  keylegend / location=inside position=topright;
run;

/* Test for GARCH Effects and Normality */
proc autoreg data=Stocks all plots(unpack);
  model VZ_r =/ archtest normal ; /*normal will test if volatility is normal*/
run;

/* Estimate Different GARCH Models */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   *garch_n:   model VZ_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   *garch_t:   model VZ_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   *qgarch:    model VZ_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
	qgarch_t:  model VZ_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   *garch_m:   model VZ_r = / garch=(p=1, q=1, mean=linear) method=ml;
   							output out=garch_m ht=predicted_var;
   *ewma:      model VZ_r = /noint garch=(p=1, q=1, type=integ,noint) method=ml BDS=(Z=SR , D=2.0);
                            output out=ewma ht=predicted_var;
   *egarch:    model VZ_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
run;
*ignore the first bit of output bc it deals with the mean, which we are not looking at here
just make sure the model converges;
*look at AIC SBC to compare models;
*ARCH1 & GARCH1 effects are your alphas and betas
--the ARCH tells us how badly a shock will affect the company (closer to 1 is worse)
--the closer the GARCH1 is to 1 the longer the company will be bothered by a shock;


/* Prepare Data for Plotting the Results */
data all_results;
  set garch_n(in=a) garch_t(in=b) egarch(in=c) qgarch_t(in=d) garch_m(in=e) ewma(in=f);
  format model $20.;
  if a then model="GARCH: Normal";
  if b then model="GARCH: T dist";
  else if c then model="Exp. GARCH";
  else if d then model="Quad. GARCH: T dist";
  else if e then model="GARCH Mean";
  else if f then model="EWMA";
run;

proc sort data=all_results;
  by model;
run;

/* Plot the Different Model Forecasts */
title;
proc gplot data=all_results /*(where=(date ge '01JAN2013'd))*/;
  plot (predicted_var)*date = model/ legend=legend1;
  plot VZ_r*date / legend=legend1;
  symbol1 i=join c=blue      w=2 v=none;
  symbol2 i=join c=green     w=2 v=none;
  symbol3 i=join c=red       w=2 v=none;
  symbol4 i=join c=magenta   w=2 v=none;
  symbol5 i=join c=black     w=2 v=none;
  symbol6 i=none c=purple    w=1 v=dot;
run;
quit;

/* Extract AIC, SBC and LIK measures */
data sbc_aic_lik;
   set fitsum_all_garch_models;
   keep Model SBC AIC Likelihood;
   if upcase(Label1)="SBC" then do; SBC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="SBC" then do; SBC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="AIC" then do; AIC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="AIC" then do; AIC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="LOG LIKELIHOOD" then do; Likelihood=input(cValue1,BEST12.4); end;
   if upcase(Label2)="LOG LIKELIHOOD" then do; Likelihood=input(cValue2,BEST12.4); end;
   if not ((SBC=.) and (Likelihood=.)) then output;
run;



/*************************XOM*********************************/

/* Load Needed Macros */
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\download.sas";
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\get_stocks.sas";

/* Get a Dataset with the Dow Jones Industrial Average (XOM) */
%let stocks = XOM;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01Mar2006,29Feb2016,keepPrice=1);

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data Stocks;
  set Stocks;
  format Date date7.;
run; 

/* Add 30 Observations for Forecasting at End of Series */
data Stocks(drop=i);
  set Stocks end = eof;
  output;
  if eof then do i=1 to 30;
    date=date+i;
    XOM_p=.;
	XOM_r=.;
    output;
  end;
run;

/* Plot the Price Data */
proc sgplot data=Stocks;
  title "XOM: Price";
  series x=date y=XOM_p;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Plot the Returns Data */
proc sgplot data=Stocks;
  title "XOM: Log Returns";
  series x=date y=XOM_r;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Fit Kernel Density-estimation on Log Returns*/
*looking at distribution of returns;
*tails are wide and slightly skewed right;
proc sgplot data=Stocks;
  title "XOM: Log Returns Kernel Density";
  density XOM_r / type=kernel;
  keylegend / location=inside position=topright;
run;

/* Test for GARCH Effects and Normality */
proc autoreg data=Stocks all plots(unpack);
  model XOM_r =/ archtest normal ; /*normal will test if volatility is normal*/
run;

/* Estimate Different GARCH Models */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   *garch_n:   model XOM_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   *garch_t:   model XOM_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   *qgarch:    model XOM_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
	qgarch_t:  model XOM_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   *garch_m:   model XOM_r = / garch=(p=1, q=1, mean=linear) method=ml;
   							output out=garch_m ht=predicted_var;
   *ewma:      model XOM_r = /noint garch=(p=1, q=1, type=integ,noint) method=ml BDS=(Z=SR , D=2.0);
                            output out=ewma ht=predicted_var;
   *egarch:    model XOM_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
run;
*ignore the first bit of output bc it deals with the mean, which we are not looking at here
just make sure the model converges;
*look at AIC SBC to compare models;
*ARCH1 & GARCH1 effects are your alphas and betas
--the ARCH tells us how badly a shock will affect the company (closer to 1 is worse)
--the closer the GARCH1 is to 1 the longer the company will be bothered by a shock;


/* Prepare Data for Plotting the Results */
data all_results;
  set garch_n(in=a) garch_t(in=b) egarch(in=c) qgarch_t(in=d) garch_m(in=e) ewma(in=f);
  format model $20.;
  if a then model="GARCH: Normal";
  if b then model="GARCH: T dist";
  else if c then model="Exp. GARCH";
  else if d then model="Quad. GARCH: T dist";
  else if e then model="GARCH Mean";
  else if f then model="EWMA";
run;

proc sort data=all_results;
  by model;
run;

/* Plot the Different Model Forecasts */
title;
proc gplot data=all_results /*(where=(date ge '01JAN2013'd))*/;
  plot (predicted_var)*date = model/ legend=legend1;
  plot XOM_r*date / legend=legend1;
  symbol1 i=join c=blue      w=2 v=none;
  symbol2 i=join c=green     w=2 v=none;
  symbol3 i=join c=red       w=2 v=none;
  symbol4 i=join c=magenta   w=2 v=none;
  symbol5 i=join c=black     w=2 v=none;
  symbol6 i=none c=purple    w=1 v=dot;
run;
quit;

/* Extract AIC, SBC and LIK measures */
data sbc_aic_lik;
   set fitsum_all_garch_models;
   keep Model SBC AIC Likelihood;
   if upcase(Label1)="SBC" then do; SBC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="SBC" then do; SBC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="AIC" then do; AIC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="AIC" then do; AIC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="LOG LIKELIHOOD" then do; Likelihood=input(cValue1,BEST12.4); end;
   if upcase(Label2)="LOG LIKELIHOOD" then do; Likelihood=input(cValue2,BEST12.4); end;
   if not ((SBC=.) and (Likelihood=.)) then output;
run;


/*************************KO*********************************/

/* Load Needed Macros */
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\download.sas";
%include "C:\Users\Hannah\Desktop\Spring 2016\Financial Analytics\Homework 2\get_stocks.sas";

/* Get a Dataset with the Dow Jones Industrial Average (KO) */
%let stocks = KO;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01Mar2006,29Feb2016,keepPrice=1);

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data Stocks;
  set Stocks;
  format Date date7.;
run; 

/* Add 30 Observations for Forecasting at End of Series */
data Stocks(drop=i);
  set Stocks end = eof;
  output;
  if eof then do i=1 to 30;
    date=date+i;
    KO_p=.;
	KO_r=.;
    output;
  end;
run;

/* Plot the Price Data */
proc sgplot data=Stocks;
  title "KO: Price";
  series x=date y=KO_p;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Plot the Returns Data */
proc sgplot data=Stocks;
  title "KO: Log Returns";
  series x=date y=KO_r;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01MAR2006"d to "01FEB2016"d by year);
run;

/* Fit Kernel Density-estimation on Log Returns*/
*looking at distribution of returns;
*tails are wide and slightly skewed right;
proc sgplot data=Stocks;
  title "KO: Log Returns Kernel Density";
  density KO_r / type=kernel;
  keylegend / location=inside position=topright;
run;

/* Test for GARCH Effects and Normality */
proc autoreg data=Stocks all plots(unpack);
  model KO_r =/ archtest normal ; /*normal will test if volatility is normal*/
run;

/* Estimate Different GARCH Models */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   *garch_n:   model KO_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   *garch_t:   model KO_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   qgarch:    model KO_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
	qgarch_t:  model KO_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   *garch_m:   model KO_r = / garch=(p=1, q=1, mean=linear) method=ml;
   							output out=garch_m ht=predicted_var;
   *ewma:      model KO_r = /noint garch=(p=1, q=1, type=integ,noint) method=ml BDS=(Z=SR , D=2.0);
                            output out=ewma ht=predicted_var;
   *egarch:    model KO_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
run;
*ignore the first bit of output bc it deals with the mean, which we are not looking at here
just make sure the model converges;
*look at AIC SBC to compare models;
*ARCH1 & GARCH1 effects are your alphas and betas
--the ARCH tells us how badly a shock will affect the company (closer to 1 is worse)
--the closer the GARCH1 is to 1 the longer the company will be bothered by a shock;


/* Prepare Data for Plotting the Results */
data all_results;
  set garch_n(in=a) garch_t(in=b) egarch(in=c) qgarch_t(in=d) garch_m(in=e) ewma(in=f);
  format model $20.;
  if a then model="GARCH: Normal";
  if b then model="GARCH: T dist";
  else if c then model="Exp. GARCH";
  else if d then model="Quad. GARCH: T dist";
  else if e then model="GARCH Mean";
  else if f then model="EWMA";
run;

proc sort data=all_results;
  by model;
run;

/* Plot the Different Model Forecasts */
title;
proc gplot data=all_results /*(where=(date ge '01JAN2013'd))*/;
  plot (predicted_var)*date = model/ legend=legend1;
  plot KO_r*date / legend=legend1;
  symbol1 i=join c=blue      w=2 v=none;
  symbol2 i=join c=green     w=2 v=none;
  symbol3 i=join c=red       w=2 v=none;
  symbol4 i=join c=magenta   w=2 v=none;
  symbol5 i=join c=black     w=2 v=none;
  symbol6 i=none c=purple    w=1 v=dot;
run;
quit;

/* Extract AIC, SBC and LIK measures */
data sbc_aic_lik;
   set fitsum_all_garch_models;
   keep Model SBC AIC Likelihood;
   if upcase(Label1)="SBC" then do; SBC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="SBC" then do; SBC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="AIC" then do; AIC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="AIC" then do; AIC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="LOG LIKELIHOOD" then do; Likelihood=input(cValue1,BEST12.4); end;
   if upcase(Label2)="LOG LIKELIHOOD" then do; Likelihood=input(cValue2,BEST12.4); end;
   if not ((SBC=.) and (Likelihood=.)) then output;
run;








