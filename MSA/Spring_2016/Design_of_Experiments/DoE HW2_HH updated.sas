%let path=C:\Users\Hannah\Desktop\Spring 2016\Marketing & Design of Experiments\Homework;

libname DoE "C:\Users\Hannah\Desktop\Spring 2016\Marketing & Design of Experiments\Homework";

ods listing gpath="C:\Users\Hannah\Desktop\plots";
/*********************************************************************************************/

/************/
/*Problem #1*/
/************/

/*Part A*/
*results: ntotal=66 or 33 for each group;
/*Actual Alpha:0.0499 Actual Power:0.805 */

PROC POWER;
	TWOSAMPLEMEANS test=diff_satt /*Satterthwaite unpooled t-test*/
		sides=1 /*Suggested that group A will be higher than B*/
		meandiff=10 /*Average expected difference*/
		groupstddevs=15|17 /*Using an unequal design since different std. deviations*/
		groupweights= 1|1 /*Equal size groups*/
		power=0.80
		alpha=0.05
		ntotal=.;
		PLOT Y=power min=0 max=1 yopts = (ref=0.80 crossref=yes)
			vary (symbol);
RUN;

/*Part B*/
*result: Actual Alpha:0.0499, Power:0.771 ;
PROC POWER;
	TWOSAMPLEMEANS test=diff_satt /*Satterthwaite unpooled t-test*/
		sides=1 /*Suggested that group A will be higher than B*/
		meandiff=10 /*Average expected difference*/
		groupstddevs=15|17 /*Using an unequal design since different std. deviations*/
		groupweights= 1|1 /*Equal size groups*/
		power=.
		alpha=0.05
		ntotal=60;
	RUN;

/************/
/*Problem #2*/
/************/

/*First Part*/

/*Balanced sample sizes*/;

DATA Doe.HW2Prob2;
	INPUT interestRate $1-5
		  sticker $7-9
		  PriceGraphic $10-15
		  responserate; /*balanced sample sizes*/
	DATALINES;
4.99% NO Small .0060  
4.99% NO Large .0075
4.99% YES Small .0080
1.99% NO Small .0085
1.99% YES Small .0100
4.99% YES Large .0100
1.99% NO Large .0100
1.99% YES Large .0120
;
RUN;

/*Assuming power of 0.80 and determining total sample size needed*/
PROC GLMPOWER DATA=Doe.HW2Prob2;
	CLASS interestRate sticker PriceGraphic;
	MODEL responserate=interestRate sticker PriceGraphic;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;

*sample size needed with all interactions included;
PROC GLMPOWER DATA=Doe.HW2Prob2;
	CLASS interestRate sticker PriceGraphic;
	MODEL responserate=interestRate|sticker|PriceGraphic;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;

*significant interactions only;
PROC GLMPOWER DATA=Doe.HW2Prob2;
	CLASS interest sticker grsize;
	MODEL responserate=interestRate sticker PriceGraphic 
						interestRate*sticker sticker*PriceGraphic;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;


/*Second Part of problem 2*/
/*Analzing last year's data*/

/*creating new data set to work with*/
data nonresponse;
set DoE.Campaign1;
	Frequency=volume-orders;
	response=0;
run;

data response;
set DoE.Campaign1;
	Frequency=orders;
	response=1;
run;

*below data set combines to 2 above to incoporate a binary variable of response and nonresponse
and calculates the response rate based on orders and volume;
data DoE.combined;
set response nonresponse;
responserate=orders/volume;
responseratepercent=responserate*100;
run;

/*Analyzing responses - running type 3 analysis on main effects only*/
ODS SELECT globalTests type3;
PROC LOGISTIC Data=DoE.combined;
	CLASS interestRate sticker priceGraphic  ;
	MODEL response(event="1")=interestRate sticker priceGraphic ;
	FREQ frequency; 
RUN; 

*type 3 analysis with all interactions--3 way interaction is significant;
ODS SELECT globalTests type3;
PROC LOGISTIC Data=DoE.combined;
	CLASS interestRate sticker priceGraphic  ;
	MODEL response(event="1")=interestRate|sticker|priceGraphic;
	FREQ frequency; 
RUN; 

*3 way interaction removed;
ODS SELECT globalTests type3;
PROC LOGISTIC Data=DoE.combined;
	CLASS interestRate sticker priceGraphic  ;
	MODEL response(event="1")=interestRate sticker priceGraphic 
							interestRate*sticker 						
							interestRate*pricegraphic
							sticker*pricegraphic;
	FREQ frequency; 
RUN; 

*pairwise test;
proc genmod data=DoE.combined
descending;
CLASS interestRate sticker priceGraphic  ;
	MODEL response=interestRate*sticker*priceGraphic/dist=bin 
	link=logit lrci;
	lsmeans interestRate*sticker*priceGraphic/diff;
	FREQ frequency; 
run;


/*sample analysis based on last year's response rates with a 0.80 power*/
PROC GLMPOWER DATA=DoE.combined (where=(response=1));
	CLASS interestRate sticker priceGraphic;
	MODEL responserate=interestRate|sticker|priceGraphic;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;

/*power analysis based on last year's test using last year's response rates 
and total sample size of 100,000 split evenly across the 8 treatments*/
PROC GLMPOWER DATA=DoE.combined (where=(response=1));
	CLASS interestRate sticker priceGraphic;
	MODEL responserate=interestRate|sticker|priceGraphic;
	POWER
		POWER=.
		NTOTAL=100000
		STDDEV=%SYSFUNC(SQRT(0.01*0.99));
RUN;
