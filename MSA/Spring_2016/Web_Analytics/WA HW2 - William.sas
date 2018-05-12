libname hw "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Web Analytics\HW\HW2";

data churn;
	set hw.churn;
run;

*CLEAN DATA*;
data churn;
	set churn;
	account_length=ceil(account_length/4.34524);
	if upcase(int_l_plan)='NO' then int_plan=0;
	if upcase(int_l_plan)='YES' then int_plan=1;
	if upcase(vmail_plan)='NO' then vm_plan=0;
	if upcase(vmail_plan)='YES' then vm_plan=1;
	if upcase(churn_)='FALSE.' then churn=0;
	if upcase(churn_)='TRUE.' then churn=1;
	calls=custserv_calls_in_the_last_year;
	if calls in(0,1,2,3) then calls_cat='LOW';
	if calls in(4,5,6,7,8,9) then calls_cat='HIG';
	drop int_l_plan vmail_plan custserv_calls_in_the_last_year churn_;
run;

*ACCT_LEN RANGES FROM 1-56 MONTHS ASSUMING CONTRACT ENDS AT END OF MONTH*;
proc means data=churn;
	var account_length;
run;

*OUTPUT SURVIVAL DATA*;
PROC LIFETEST DATA=churn
    METHOD=LIFE
    INTERVALS=0 TO 56 BY 1
    OUTSURV=out1
    PLOTS=all;
  TIME account_length*churn(0);
RUN;

PROC LIFETEST DATA=churn OUTSURV=out1;
  TIME account_length*churn(0);
RUN;

*CALCULATE N & SUM(T,C)*;
PROC MEANS DATA=churn SUM MAXDEC=0;
   VAR churn account_length ;
   WEIGHT account_length;
   OUTPUT OUT=sumtc SUM=;
RUN;

*SIMPLE RETENTION MODEL - CONTANT RATE - CALCULATE RHAT*;
DATA out2;
  SET out1;
  BY account_length;
  IF account_length>0 AND FIRST.account_length;
  rhat = 1-(11660/2162083);
  clv = survival*26/(1.01**(account_length-1));
  survSRM = (rhat)**(account_length-1);
  clvSRM = 26*(rhat/1.01)**(account_length-1);
RUN;

*PRINT CLV BY T;
PROC PRINT DATA=out2 NOOBS;
  VAR account_length survival survSRM clv clvSRM;
  SUM clv clvSRM;
  FORMAT clv clvSRM DOLLAR8.2;
RUN;

*COMPUTE RETENTION RATE*;
PROC SQL;
   SELECT
   	cancels LABEL="Number Cancels",
	flips LABEL ="Opportunities to Cancel", 
	Rhat LABEL ="Retention Rate (r)" FORMAT=6.4,
	1/(1-Rhat) AS ET LABEL= "E(T)" FORMAT=5.1, 
	1+LOG(0.5)/LOG(Rhat) AS median LABEL ="Median(T)" FORMAT=3.0,
	(26*Rhat)/(1.01-Rhat) as E_CLV
   FROM (SELECT SUM(churn) AS cancels,
	  SUM(account_length) as flips,
	  1-SUM(churn)/SUM(account_length) as Rhat
   	FROM sumtc); quit;

*STRATIFY BY FACTOR*;
PROC LIFETEST DATA=churn;
  STRATA gender;
  TIME account_length*churn(0);
RUN;

PROC LIFETEST DATA=churn;
  STRATA int_plan;
  TIME account_length*churn(0);
RUN;

PROC LIFETEST DATA=churn;
  STRATA vm_plan;
  TIME account_length*churn(0);
RUN;

PROC LIFETEST DATA=churn;
  STRATA calls;
  TIME account_length*churn(0);
RUN;

PROC LIFETEST DATA=churn;
  STRATA state;
  TIME account_length*churn(0);
RUN;

PROC LIFETEST DATA=churn;
  STRATA area_code;
  TIME account_length*churn(0);
RUN;
*INT, VM, CALLS, AND STATE SIGNIFICANT*;

*CHECK IF NEWLY BINNED CALLS IS SIGNIFICANT*;
PROC LIFETEST DATA=churn;
  STRATA calls_cat;
  TIME account_length*churn(0);
RUN;


