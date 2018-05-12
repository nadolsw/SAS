/*-------------------------------*/
/* Estimation Using Monte Carlo  */
/*       Simulation & CI's       */
/*                               */
/*        Dr Aric LaBarr         */
/*-------------------------------*/


/* Load Needed Macros */
%include "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Simulation & Risk\Code\download.sas";
%include "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Simulation & Risk\Code\get_stocks.sas";

/* Get a Dataset with the Apple and Microsoft Stocks */
%let stocks =aapl msft;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01JAN2010,,keepPrice=1);

/* Setable Parameters - Holdings and VaR Confidence Level */
%let msft_holding = 1700; 
%let aapl_holding = 2500;  
%let var_percentile = 0.05;
%let n_simulations = 10000;
/*==================================================================*/


/* Calculate the Needed Variances and Covariances */
proc corr data=stocks cov out=covar_results plots;
	var msft_r aapl_r;
run;

data _null_;
	set covar_results(where = (_type_ eq 'COV'));
	if upcase(_name_) eq 'MSFT_R' then do;
		call symput("var_msft",msft_r);
		call symput("covar",aapl_r);
	end;
	if upcase(_name_) eq 'AAPL_R' then do;
		call symput("var_aapl",aapl_r);
	end;
run;

data _null_;
	set covar_results(where = (_type_ eq 'CORR'));
	if upcase(_name_) eq 'MSFT_R' then do;
		call symput("corr",aapl_r);
	end;
run;


/* Calculate Current Price of Holdings (Portfolio) */
data _null_;
	set stocks end=eof;
	if eof then do;
   		call symput("msft_p",msft_p);
   		call symput("aapl_p",aapl_p);
	end;
run; 


/* Monte Carlo Simulation Approach */ 
data Corr_Matrix;
	do i=1 to &n_simulations;
		_type_ = "corr";
		_name_ = "msft_r";

  		msft_r = 1.0; 
  		aapl_r = &corr;

  		output;
  		_name_ = "aapl_r";

		msft_r = &corr; 
  		aapl_r = 1.0;

  		output;
	end;
run;

data Naive;
	do i=1 to &n_simulations;
  		msft_r=0;
  		aapl_r=0;
  		output;
	end;
run;

proc model noprint;

	msft_r = 0;
	errormodel msft_r ~Normal(&var_msft);

	aapl_r = 0;
	errormodel aapl_r ~Normal(&var_aapl);

	solve msft_r aapl_r/ random=1 sdata=Corr_Matrix
	data=Naive out=mc_stocks(keep=msft_r aapl_r i);
		by i;

run;
quit;

data mc_stocks;
	set mc_stocks;
	by i;
	if first.i then delete;
	rename i=simulation;
	value = &msft_holding*(exp(msft_r + log(&msft_p))) + &aapl_holding*(exp(aapl_r + log(&aapl_p)));
	value_change = value - (&msft_holding*&msft_p + &aapl_holding*&aapl_p);
	format value_change dollar15.2;
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


/* Confidence Interval for Value at Risk - Normal Approximation Estimation */
proc univariate data=mc_stocks cipctlnormal;
	var value_change;
run;


/* Confidence Interval for Value at Risk - Distribution Free Estimation */
proc univariate data=mc_stocks cipctldf;
	var value_change;
run;


/* Confidence Interval for Value at Risk - Bootstrap Approach */
%let n_bootstraps=1000;
%let bootstrap_prop=0.1;

proc surveyselect data=mc_stocks out=outboot seed=12345 method=srs 
				  samprate=&bootstrap_prop rep=&n_bootstraps noprint;
run; 

proc univariate data=outboot noprint;
	var value_change;
	output out=boot_var pctlpts = &var_clevel pctlpre=P;
	by replicate;
run;

proc univariate data=boot_var;
	var P5;
	output out=var_ci pctlpts = 2.5 97.5 pctlpre=P;
run;

proc print data=var_ci;
run;


/* Confidence Interval for Conditional Value at Risk - Bootstrap Approach */
%let n_bootstraps=1000;
%let bootstrap_prop=%sysevalf(&n_bootstraps/&n_simulations);

proc surveyselect data=mc_stocks out=outboot_es seed=12345 method=srs 
				  samprate=&bootstrap_prop rep=&n_bootstraps noprint;
run; 

proc sort data=outboot_es;
	by replicate value_change;
run;

data outboot_es;
	set outboot_es;
	obs = mod(_N_, &n_bootstraps);
	if obs = 0 then obs = &n_bootstraps;
run;

data outboot_es;
	set outboot_es;
	where obs < %sysevalf(&var_percentile*&n_bootstraps);
run;

proc means data=outboot_es mean noprint;
	var value_change;
	by replicate;
	output out=boot_es mean = CVaR;
run;

proc univariate data=boot_es;
	var CVaR;
	output out=cvar_ci pctlpts = 2.5 97.5 pctlpre=P;
run;

proc print data=cvar_ci;
run;
