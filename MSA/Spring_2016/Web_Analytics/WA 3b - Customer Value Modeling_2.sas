libname data "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Web Analytics\Data";

data data.service5yr;
	set service5yr;
run;

************************CUSTOMER LIFETIME VALUE MODELING using KLM and LIFETABLE METHODS*****************;
****USE LIFE TABLE METHOD FOR THE SURVIVAL FUNCTION using service5yr dataset*****;
PROC PRINT DATA=service5yr (OBS=10);
RUN;
PROC LIFETEST DATA=service5yr
    METHOD=LIFE
    INTERVALS=0 TO 60 BY 1
    OUTSURV=out1
    PLOTS=(S,H,P);
  TIME bigT*cancel(0);
  FREQ count;
RUN;

/*Use KM method to generate long term value estimates, 
OUTSURV option creates data with survival probabilities;
survSRM column gives survival function with SRM model for comparison*/
PROC LIFETEST DATA=service5yr OUTSURV=out1;
  TIME bigT*cancel(0);
  FREQ count;
RUN;

proc sort data=service5yr; by cancel; run;


PROC MEANS DATA=service5yr SUM MAXDEC=0;
   VAR cancel bigT;
   WEIGHT count;
   OUTPUT OUT=answer SUM=;
RUN;


*SIMPLE RETENTION MODEL - CONTANT RATE*;
DATA out1;
  SET out1;
  BY bigT;
  IF bigT>0 AND FIRST.bigT;
  rhat = 1-44367/1073935;
  clv = survival*23.20/(1.01**(bigT-1));
  survSRM = (rhat)**(bigT-1);
  clvSRM = 23.20*(rhat/1.01)**(bigT-1);
RUN;

PROC PRINT DATA=out1 NOOBS;
  VAR bigT survival survSRM clv clvSRM;
  SUM clv clvSRM;
  FORMAT clv clvSRM DOLLAR8.2;
RUN;


/* Comparing subgroups with stratification: startlen varible 
-length in months for the starting contract using STRATA statement*/

PROC LIFETEST DATA=service5yr OUTSURV=out2;
  STRATA startlen;
  TIME bigT*cancel(0);
  FREQ count;
RUN;

DATA out2;
  SET out2;
  BY startlen bigT;
  IF bigT>0 AND FIRST.bigT;
  clv = survival*23.20/(1.01**(bigT-1));
RUN;

PROC PRINT DATA=out2 NOOBS;
  BY startlen;
  VAR bigT survival clv;
  SUM clv;
  FORMAT clv DOLLAR8.2;
RUN;


/* Discrete time model without covariates */

/*1.SRM with logistic regression-service1yr data*/

/*Transform the data first so that logistic regression can be used
t=time period in customer's life; cancelnow is dummy var that equals 1
if a customer canceled during a certain period; weight cases by count*/

DATA long;
  SET service1yr;
  DO t = 1 to bigT;
    cancelnow = cancel*(t=bigT);
    OUTPUT;
  END;
RUN;
PROC PRINT DATA=long (obs=10);
RUN;

PROC LOGISTIC DATA=long DESCENDING;
  MODEL cancelnow = ;
  FREQ count;
RUN;

/*We can calculate the estimated prob. of canceling using the estimate 
-3.1262 in the regression equation,Prob = 0.0420 for all customers so 
the retention rate = 1-0.0420 = .958*/

/*2.Varying retention rates- logistic regression-service1yr data*/
/*Estimate the logistic regression predicting cancelnow form t as a 
categorical variable so that each month has a different retention rate*/

/*We have to first create dummy variables for individual time periods
and use the dummies as predictor variables*/


PROC LOGISTIC DATA=long DESCENDING;
  CLASS t / PARAM=REF;
  MODEL cancelnow = t;
  FREQ count;
  OUTPUT OUT=probs PREDICTED=phat;
RUN;
/*calculating rhat = 1/(1+e^estimate) from parameter estimate table
e.g., the intercept row gives the log odds ratio for the month 12 default rate-2.715
=1/1+e^2.6715=0.0647, rhat=1-0.0647=0.9353*/
PROC SQL;
  SELECT
    DISTINCT t,
    1-phat AS rhat FORMAT=7.4
  FROM probs;


/* Discrete time model without covariates */
  /*Model data using static covariates*/
  /*Use dataset service2 for the Educational Service provider 
  wiht start contract length as the covariate*/
  /*pay 0-pay11 are contract length for 12 months, =0 means
  the customer is no longer a member; test0-11 are number of tests submitted
  by a student in a particular month*/

PROC PRINT DATA=service2 (OBS=10);
  VAR pay0-pay11 test0-test11;
  id custid;
RUN;
/*Prepare data for PROC LOGISTIC. There should be one record for 
every opportunity to cancel. Because noone cancels at time 0, loop starts at 1*/
DATA long;
  SET service2;
  ARRAY pay{0:11} pay0-pay11;
  ARRAY test{0:11} test0-test11;
  startlen = pay0;
  cancelnow = 0;
  DO t = 1 TO 11 UNTIL(pay{t}=0);
    lagnotest = (test{t-1}=0);
    cancelnow = (pay{t}=0);
    OUTPUT;
  END;
  KEEP custid startlen t cancelnow lagnotest;
RUN;
PROC PRINT DATA=long NOOBS;
  BY custid;
  VAR t startlen cancelnow lagnotest;
  WHERE custid IN (137,139,143);
RUN;


/* MODEL WITH STATIC COVARIATE */


PROC LOGISTIC DATA=long DESCENDING;
  CLASS t startlen / PARAM=REF;
  MODEL cancelnow = t startlen;
  ESTIMATE "1 vs 6 month" startlen 1 -1;
RUN;


/* Modeling interaction between t and startlen */


PROC LOGISTIC DATA=long DESCENDING;
  CLASS t startlen / PARAM=REF;
  MODEL cancelnow = t|startlen;
RUN;

/* MODEL WITH TIME DEPENDENT COVARIATE */

/*Whether a student submitted a test during a previous month (lagnotest)*/


PROC LOGISTIC DATA=long DESCENDING;
  CLASS t startlen / PARAM=REF;
  MODEL cancelnow = t|startlen lagnotest;
RUN;

