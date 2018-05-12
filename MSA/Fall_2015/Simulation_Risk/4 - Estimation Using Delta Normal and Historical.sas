/*-------------------------------*/
/* Estimation Using Delta Normal */
/*   & Historical Simulation     */
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
%let var_percentile=0.05;
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

/* Calculate Current Total Value of Holdings (Portfolio) */
data _null_;
	set stocks end=eof;
	if eof then do;
   		msft_position= msft_p*&msft_holding;call symput("msft_position",msft_position);
   		aapl_position= aapl_p*&aapl_holding;call symput("aapl_position",aapl_position);
		call symput("number_of_observations",_n_);
	end;
run; 

/* Variance-Covariance Approach */ 
proc iml;
title 'VaR Results';

/* Calculate Portfolio Holding Weights */
msft_p_weight = &msft_position/(&msft_position + &aapl_position);
aapl_p_weight = &aapl_position/(&msft_position + &aapl_position);

/* Calculate Portfolio Variance */
P_variance =  &var_msft*(msft_p_weight)**2 + &var_aapl*(aapl_p_weight)**2 
                   + 2*aapl_p_weight*msft_p_weight*&covar;
P_StdDev=sqrt(P_variance);
print P_StdDev;

/* Confidence Intervals for Portfolio Standard Deviation */
sigma_low = sqrt(P_variance*(&number_of_observations-1)/cinv((1-(&var_percentile/2)),&number_of_observations-1) );
sigma_up = sqrt(P_variance*(&number_of_observations-1)/cinv((&var_percentile/2),&number_of_observations-1) );
print sigma_low sigma_up;

/* Calculate Portfolio's Value at Risk, VaR CI, and Conditional Value at Risk */
VaR_normal = (&msft_position + &aapl_position)*PROBIT(&var_percentile)*SQRT(P_variance);
VaR_L= (&msft_position + &aapl_position)*PROBIT(&var_percentile)*(sigma_low);
VaR_U= (&msft_position + &aapl_position)*PROBIT(&var_percentile)*(sigma_up);
print var_normal var_l var_u;
pi=3.14159265;
ES_normal = -(&msft_position + &aapl_position)*SQRT(P_variance)*exp(-0.5*(PROBIT(&var_percentile))**2)/(&var_percentile.*sqrt(2*pi));

print "Daily VaR (Percentile level: &var_percentile); Delta-Normal" VaR_normal[format=dollar15.2];

print "Daily CVaR/ES (Percentile level: &var_percentile); Delta-Normal" ES_normal[format=dollar15.2];

quit;



/* Historical Simulation Approach - PROC IML */
proc iml;

/* Read in Stocks Data */
USE stocks var {msft_r aapl_r}; 
read all var _all_ into returns;

/* Calculate Portfolio Return */
portfolio_return = &msft_position*returns[,1] + &aapl_position*returns[,2];

/* Sort Portfolio Values */
call sort(portfolio_return,{1});
number_of_observations = nrow(portfolio_return);

/* Find Value at Risk Observation */
obs_to_use = round(&var_percentile*number_of_observations,1)+1;

VaR_historical = portfolio_return[obs_to_use,1];

PRINT "Daily VaR (Percentile level: &var_percentile); Historical" VaR_historical[format=dollar15.2];

/* Calculate the ES */
ES = sum(portfolio_return[1:obs_to_use,1])/(obs_to_use-1);
PRINT "Daily CVaR/ES (Percentile level: &var_percentile level); Historical" ES[format=dollar15.2];


title;
QUIT;


/* Historical Simulation Approach - PROC's and Data Steps */
data stocks_new;
	set stocks;
	value = &msft_position*msft_r + &aapl_position*aapl_r;
run;

%let var_clevel=%sysevalf(100*&var_percentile);

proc univariate data=stocks_new;
	var value;
	histogram value;
	output out=percentiles pctlpts = &var_clevel pctlpre=P;
run;

proc print data=percentiles;
run;

data _null_;
	set percentiles;
	call symput("var_p",P5);
run;

proc means data=stocks_new mean;
	var value;
	where value < &var_p;
run;
