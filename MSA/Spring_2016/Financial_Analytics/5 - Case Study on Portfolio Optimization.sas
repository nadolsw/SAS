/*-------------------------------*/
/*          Case Study           */
/*    Portfolio Optimization     */
/*                               */
/*        Dr Aric LaBarr         */
/*-------------------------------*/


/* Load Needed Macros */
%include "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Simulation & Risk\Code\download.sas";
%include "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Simulation & Risk\Code\get_stocks.sas";

/* Get a Dataset with the Technology Stocks */
%let stocks = msft aapl googl pypl ebay;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01JAN2008,24FEB2016,keepPrice=1);

/* Setable Parameters - Simulation Count and Investment Amount */ 
%let initial = 1000000;
%let n_simulations = 10000;

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data Stocks;
  set Stocks;
  format Date date7.;
run; 

/* Calculate Current Price of Holdings (Portfolio) */
data _null_;
	set stocks end=eof;
	if eof then do;
   		call symput("msft_p",msft_p);
   		call symput("aapl_p",aapl_p);
		call symput("googl_p",googl_p);
		call symput("pypl_p",pypl_p);
		call symput("ebay_p",ebay_p);
		call symput("msft_r",msft_r);
   		call symput("aapl_r",aapl_r);
		call symput("googl_r",googl_r);
		call symput("pypl_r",pypl_r);
		call symput("ebay_r",ebay_r);
	end;
run; 

/* Add 10 Observations for Forecasting at End of Series */
data Stocks(drop=i);
  set Stocks end = eof;
  output;
  if eof then do i=1 to 10;
    date=date+i;
    msft_p=.; msft_r=.;
	aapl_p=.; aapl_r=.;
	googl_p=.; googl_r=.;
	pypl_p=.; pypl_r=.;
	ebay_p=.; ebay_r=.;
    output;
  end;
run;
/*==================================================================*/


/* Calculate the Correlation Between the Stocks */
proc corr data=stocks cov out=Corr;
	var msft_r aapl_r googl_r pypl_r ebay_r;
run; 

data Cov;
	set Corr;
	where _TYPE_='COV';
run;

data Mean;
	set Corr;
	where _TYPE_='MEAN';
run;

/* Optimize the Portfolio */
proc optmodel;

	/* Declare Sets and Parameters */
	set <str> Assets1, Assets2, Assets3;
	num Covariance{Assets1,Assets2};
	num Mean{Assets1};
*CREATE TWO MATRICES WHERE SIZE IS BASED ON UNIQUE VALUES IN A VECTOR -
 NUMBER OF ROWS IN MATRIX IS ASSET1, NUMBER OF COLUMNS IS ASSET2*;

	/* Read in SAS Data Sets */
	read data Cov into Assets1=[_NAME_];
	read data Cov into Assets2=[_NAME_] {i in Assets1} <Covariance[i,_NAME_]=col(i)>;
	read data Mean into Assets3=[_NAME_] {i in Assets1} <Mean[i]=col(i)>;
*I IS ROW - J IS COLUMN*;

	/* Declare Variables */
	var Proportion{Assets1}>=0 init 0;
*REQUIRE VALUES GT ZERO - INITIALIZE VALUE TO ZERO*;

	/* Declare Objective Function */
	min Risk = sum{i in Assets1}(sum{j in Assets1}Proportion[i]*Covariance[i,j]*Proportion[j]);

	/* Declare Constraints */
	con Return: 0.0005 <= sum{i in Assets1}Proportion[i]*Mean[i];
*RETURNS ARE ON A DAILY BASIS - .0005 CORRESPONDS TO ~9% ANNUAL YIELD*;
	con Sum: 1 = sum{i in Assets1}Proportion[i];
*SUM OF PROPORTIONS MUST EQUAL ONE*;

	*con RisklessReturn: 0.0005 <= sum{i in Assets1}Proportion[i]*Mean[i] + (1 - sum{i in Assets1}Proportion[i])*0.0000137;

	/* Call the Solver */
	solve;

	/* Print Solutions */
	print Covariance Mean;
	print Proportion 'Sum ='(sum{i in Assets1}Proportion[i]);
*VERIFY PROPORTIONS SUM TO ONE*;

	/* Output Results */
	create data Weight from [Assets1] Proportion;

quit;
/*==================================================================*/


/* Assigning Monetary Value to Weights */
data Weight;
	set Weight;
	Value = &initial*Proportion;
	if Assets1 = "msft_r" then Holdings = Value / &msft_p;
	if Assets1 = "aapl_r" then Holdings = Value / &aapl_p;
	if Assets1 = "googl_r" then Holdings = Value / &googl_p;
	if Assets1 = "pypl_r" then Holdings = Value / &pypl_p;
	if Assets1 = "ebay_r" then Holdings = Value / &ebay_p;
	Holdings = ROUND(Holdings, 1);

	if Assets1 = "msft_r" then Round_Holdings = Holdings*&msft_p;
	if Assets1 = "aapl_r" then Round_Holdings = Holdings*&aapl_p;
	if Assets1 = "googl_r" then Round_Holdings = Holdings*&googl_p;
	if Assets1 = "pypl_r" then Round_Holdings = Holdings*&pypl_p;
	if Assets1 = "ebay_r" then Round_Holdings = Holdings*&ebay_p;

	if Assets1 = "msft_r" then do;
		call symput("msft_holding",Holdings);
	end;
	if Assets1 = "aapl_r" then do;
		call symput("aapl_holding",Holdings);
	end;
	if Assets1 = "googl_r" then do;
		call symput("googl_holding",Holdings);
	end;
	if Assets1 = "pypl_r" then do;
		call symput("pypl_holding",Holdings);
	end;
	if Assets1 = "ebay_r" then do;
		call symput("ebay_holding",Holdings);
	end;
run;

proc means data=Weight sum;
	var Round_Holdings;
run;


/* Monte Carlo Simulation Approach */ 
data Corr;
	set Corr;
	if _TYPE_ ne "CORR" then delete;
run;

data Corr_Matrix;
	set Corr;
run;

%macro corr_repeat(reps);
	%do i = 1 %to (&reps - 1);

	data Corr_Matrix;
		set Corr_Matrix Corr;
	run;
	%end;

%mend;

%corr_repeat(&n_simulations);

data attach(drop= k j);
	do k = 1 to &n_simulations;
		do j = 1 to &n_stocks;
			i = k;
		output;
		end;
	end;
run;

data Corr_Matrix;
	merge Corr_Matrix attach;
run;

data Naive (drop=_TYPE_ _NAME_);
	set Mean;
	do i=1 to &n_simulations;
  		output;
	end;
run;

proc model noprint;

	msft_r = &msft_r;
	errormodel msft_r ~Normal(0.0003462106);

	aapl_r = &aapl_r;
	errormodel aapl_r ~Normal(0.0004434668);

	googl_r = &googl_r;
	errormodel googl_r ~Normal(0.0003865013);

	pypl_r = &pypl_r;
	errormodel pypl_r ~Normal(0.0005384187);

	ebay_r = &ebay_r;
	errormodel ebay_r ~Normal(0.000514577);

	solve msft_r aapl_r googl_r pypl_r ebay_r / random=1 sdata=Corr_Matrix
	data=Naive out=mc_stocks(keep=msft_r aapl_r googl_r pypl_r ebay_r i);
		by i;

run;
quit;

data mc_stocks;
	set mc_stocks;
	by i;
	if first.i then delete;
	rename i=simulation;
	value = &msft_holding*(exp(msft_r + log(&msft_p))) + &aapl_holding*(exp(aapl_r + log(&aapl_p)))
			+ &googl_holding*(exp(googl_r + log(&googl_p)))+ &pypl_holding*(exp(pypl_r + log(&pypl_p)))
			+ &ebay_holding*(exp(ebay_r + log(&ebay_p)));
	value_change = value - (&msft_holding*&msft_p + &aapl_holding*&aapl_p + &googl_holding*&googl_p
							+ &pypl_holding*&pypl_p + &ebay_holding*&ebay_p);
	format value_change dollar15.2;
	format value dollar15.2;
run;

%let var_clevel=%sysevalf(100*&var_percentile);

proc univariate data=mc_stocks;
	var value_change;
	format value_change dollar15.2;
	output out=percentiles pctlpts = &var_clevel pctlpre=P;
	histogram value_change / kernel normal;
run;

proc print data=percentiles;
run;

data _null_;
	set percentiles;
	call symput("var_p",P5);
run;

proc means data=mc_stocks mean;
	var value_change;
	where value_change < &var_p;
run;

proc sgplot data=mc_stocks;
	title 'One Day Value Distribution of Tech Portfolio';
	histogram value_change;
	xaxis min = -100000 max = 100000;
	refline 0 / axis=x label='No Change' lineattrs=(color=blue thickness=2);
	keylegend / location=inside position=topright;
	refline -17533.62 / axis=x label='5% VaR' lineattrs=(color=red thickness=2);
	keylegend / location=inside position=topright;
run;

proc sgplot data=mc_stocks;
	title 'One Day Value Distribution of Tech Portfolio';
	histogram value;
	xaxis min = 900000 max = 1100000;
	refline 1000000 / axis=x label='Initial Inv.' lineattrs=(color=blue thickness=2);
	keylegend / location=inside position=topright;
	refline 982466.38 / axis=x label='5% VaR' lineattrs=(color=red thickness=2);
	keylegend / location=inside position=topright;
run;
/*==================================================================*/


/* Test for GARCH Effects and Normality */
proc autoreg data=Stocks;
   model msft_r =/ archtest normal;
   model aapl_r =/ archtest normal;
   model googl_r =/ archtest normal;
   model pypl_r =/ archtest normal;
   model ebay_r =/ archtest normal;
run;

/* Estimate Different GARCH Models - MSFT */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   garch_n:   model msft_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   garch_t:   model msft_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   egarch:    model msft_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
   qgarch_t:  model msft_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   qgarch:    model msft_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
run;

/* Extract AIC, SBC and LIK measures - MSFT */
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

/* Estimate Different GARCH Models - AAPL */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   garch_n:   model aapl_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   garch_t:   model aapl_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   egarch:    model aapl_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
   qgarch_t:  model aapl_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   qgarch:    model aapl_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
run;

/* Extract AIC, SBC and LIK measures - AAPL */
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

/* Estimate Different GARCH Models - GOOGL */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   garch_n:   model googl_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   garch_t:   model googl_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   egarch:    model googl_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
   qgarch_t:  model googl_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   qgarch:    model googl_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
run;

/* Extract AIC, SBC and LIK measures - GOOGL */
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

/* Estimate Different GARCH Models - EBAY */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=Stocks OUTEST=param_estimates;
   garch_n:   model ebay_r =  / garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   garch_t:   model ebay_r =  / garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   egarch:    model ebay_r = / garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
   qgarch_t:  model ebay_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   qgarch:    model ebay_r = / garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
run;

/* Extract AIC, SBC and LIK measures - EBAY */
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

/* Estimate Different GARCH Models */
proc autoreg data=Stocks OUTEST=param_estimates;
   MSFT_qgarch_t:   model msft_r =  / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=msft_qgarch_t ht=pred_var_msft;
   AAPL_qgarch_t:   model aapl_r =  / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=aapl_qgarch_t ht=pred_var_aapl;
   GOOGL_qgarch_t:    model googl_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=googl_qgarch_t ht=pred_var_googl;
   EBAY_qgarch_t:  model ebay_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=ebay_qgarch_t ht=pred_var_ebay;
run;

data param_estimates;
	set param_estimates;
	t_df = 1 / _TDFI_;
run;

data _null_;
	set param_estimates;
	if _DEPVAR_ eq "msft_r" then do;
		call symput("t_msft",t_df);
	end;
	if _DEPVAR_ eq "aapl_r" then do;
		call symput("t_aapl",t_df);
	end;
	if _DEPVAR_ eq "googl_r" then do;
		call symput("t_googl",t_df);
	end;
	if _DEPVAR_ eq "ebay_r" then do;
		call symput("t_ebay",t_df);
	end;
run;

/* Get New Forecasted Values for Variance */
data combined (keep=date pred_var_msft pred_var_aapl pred_var_googl pred_var_ebay);
	merge msft_qgarch_t aapl_qgarch_t googl_qgarch_t ebay_qgarch_t;
	if date <= '24FEB2016'd then delete;
run;

data _null_;
	set combined(where = (date eq '25FEB2016'd));
	call symput("msft_pred", pred_var_msft);
	call symput("aapl_pred", pred_var_aapl);
	call symput("googl_pred", pred_var_googl);
	call symput("ebay_pred", pred_var_ebay);
run;

data Cov;
	set Cov;
	if _NAME_="msft_r" then msft_r=&msft_pred;
	if _NAME_="aapl_r" then aapl_r=&aapl_pred;
	if _NAME_="googl_r" then googl_r=&googl_pred;
	if _NAME_="ebay_r" then ebay_r=&ebay_pred;
run;
/*==================================================================*/


/* Optimize the Portfolio After GARCH Adjustments to Variance */
proc optmodel;

	/* Declare Sets and Parameters */
	set <str> Assets1, Assets2, Assets3;
	num Covariance{Assets1,Assets2};
	num Mean{Assets1};

	/* Read in SAS Data Sets */
	read data Cov into Assets1=[_NAME_];
	read data Cov into Assets2=[_NAME_] {i in Assets1} <Covariance[i,_NAME_]=col(i)>;
	read data Mean into Assets3=[_NAME_] {i in Assets1} <Mean[i]=col(i)>;

	/* Declare Variables */
	var Proportion{Assets1}>=0 init 0;

	/* Declare Objective Function */
	min Risk = sum{i in Assets1}(sum{j in Assets1}Proportion[i]*Covariance[i,j]*Proportion[j]);

	/* Declare Constraints */
	con Return: 0.0005 <= sum{i in Assets1}Proportion[i]*Mean[i];
	con Sum: 1 = sum{i in Assets1}Proportion[i];
	*con RisklessReturn: 0.0005 <= sum{i in Assets1}Proportion[i]*Mean[i] + (1 - sum{i in Assets1}Proportion[i])*0.0000137;

	/* Call the Solver */
	solve;

	/* Print Solutions */
	print Covariance Mean;
	print Proportion 'Sum ='(sum{i in Assets1}Proportion[i]);

	/* Output Results */
	create data Weight from [Assets1] Proportion;

quit;
/*==================================================================*/


/* Assigning Monetary Value to Weights */
data Weight;
	set Weight;
	Value = &initial*Proportion;
	if Assets1 = "msft_r" then Holdings = Value / &msft_p;
	if Assets1 = "aapl_r" then Holdings = Value / &aapl_p;
	if Assets1 = "googl_r" then Holdings = Value / &googl_p;
	if Assets1 = "pypl_r" then Holdings = Value / &pypl_p;
	if Assets1 = "ebay_r" then Holdings = Value / &ebay_p;
	Holdings = ROUND(Holdings, 1);

	if Assets1 = "msft_r" then Round_Holdings = Holdings*&msft_p;
	if Assets1 = "aapl_r" then Round_Holdings = Holdings*&aapl_p;
	if Assets1 = "googl_r" then Round_Holdings = Holdings*&googl_p;
	if Assets1 = "pypl_r" then Round_Holdings = Holdings*&pypl_p;
	if Assets1 = "ebay_r" then Round_Holdings = Holdings*&ebay_p;

	if Assets1 = "msft_r" then do;
		call symput("msft_holding",Holdings);
	end;
	if Assets1 = "aapl_r" then do;
		call symput("aapl_holding",Holdings);
	end;
	if Assets1 = "googl_r" then do;
		call symput("googl_holding",Holdings);
	end;
	if Assets1 = "pypl_r" then do;
		call symput("pypl_holding",Holdings);
	end;
	if Assets1 = "ebay_r" then do;
		call symput("ebay_holding",Holdings);
	end;
run;

proc means data=Weight sum;
	var Round_Holdings;
run;


/* Monte Carlo Simulation Approach */ 
data Corr;
	set Corr;
	if _TYPE_ ne "CORR" then delete;
run;

data Corr_Matrix;
	set Corr;
run;

%macro corr_repeat(reps);
	%do i = 1 %to (&reps - 1);

	data Corr_Matrix;
		set Corr_Matrix Corr;
	run;
	%end;

%mend;

%corr_repeat(&n_simulations);

data attach(drop= k j);
	do k = 1 to &n_simulations;
		do j = 1 to &n_stocks;
			i = k;
		output;
		end;
	end;
run;

data Corr_Matrix;
	merge Corr_Matrix attach;
run;

data Naive (drop=_TYPE_ _NAME_);
	set Mean;
	do i=1 to &n_simulations;
  		output;
	end;
run;

proc model noprint;

	msft_r = &msft_r;
	errormodel msft_r ~t(&msft_pred, &t_msft);

	aapl_r = &aapl_r;
	errormodel aapl_r ~t(&aapl_pred, &t_aapl);

	googl_r = &googl_r;
	errormodel googl_r ~t(&googl_pred, &t_googl);

	pypl_r = &pypl_r;
	errormodel pypl_r ~Normal(0.0005384187);

	ebay_r = &ebay_r;
	errormodel ebay_r ~t(&ebay_pred, &t_ebay);

	solve msft_r aapl_r googl_r pypl_r ebay_r / random=1 sdata=Corr_Matrix
	data=Naive out=mc_stocks(keep=msft_r aapl_r googl_r pypl_r ebay_r i);
		by i;

run;
quit;

data mc_stocks;
	set mc_stocks;
	by i;
	if first.i then delete;
	rename i=simulation;
	value = &msft_holding*(exp(msft_r + log(&msft_p))) + &aapl_holding*(exp(aapl_r + log(&aapl_p)))
			+ &googl_holding*(exp(googl_r + log(&googl_p)))+ &pypl_holding*(exp(pypl_r + log(&pypl_p)))
			+ &ebay_holding*(exp(ebay_r + log(&ebay_p)));
	value_change = value - (&msft_holding*&msft_p + &aapl_holding*&aapl_p + &googl_holding*&googl_p
							+ &pypl_holding*&pypl_p + &ebay_holding*&ebay_p);
	format value_change dollar15.2;
	format value dollar15.2;
run;

%let var_clevel=%sysevalf(100*&var_percentile);

proc univariate data=mc_stocks;
	var value_change;
	format value_change dollar15.2;
	output out=percentiles pctlpts = &var_clevel pctlpre=P;
	histogram value_change / kernel normal;
run;

proc print data=percentiles;
run;

data _null_;
	set percentiles;
	call symput("var_p",P5);
run;

proc means data=mc_stocks mean;
	var value_change;
	where value_change < &var_p;
run;

proc sgplot data=mc_stocks;
	title 'One Day Value Distribution of Tech Portfolio / GARCH';
	histogram value_change;
	xaxis min = -100000 max = 100000;
	refline 0 / axis=x label='No Change' lineattrs=(color=blue thickness=2);
	keylegend / location=inside position=topright;
	refline -21164.30 / axis=x label='5% VaR' lineattrs=(color=red thickness=2);
	keylegend / location=inside position=topright;
run;

proc sgplot data=mc_stocks;
	title 'One Day Value Distribution of Tech Portfolio / GARCH';
	histogram value;
	xaxis min = 900000 max = 1100000;
	refline 1000000 / axis=x label='Initial Inv.   ' lineattrs=(color=blue thickness=2);
	keylegend / location=inside position=topright;
	refline 978835.70 / axis=x label='5% VaR   ' lineattrs=(color=red thickness=2);
	keylegend / location=inside position=topright;
run;
