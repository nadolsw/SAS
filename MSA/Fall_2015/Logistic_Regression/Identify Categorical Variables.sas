libname annuity "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework";

***SAVE NLEVELS INFO TO TEMPORARY DATASET***;
ods trace on / listing;
ods output nlevels=nlevelsds;

proc freq data=annuity.insurance_t nlevels;
tables _all_/noprint;
run;

***RETRIEVE VARIABLE TYPES***;
proc sql noprint;
select name,type
from dictionary.columns
where libname='ANNUITY' and memname='INSURANCE_T';
quit;

***MERGE VARIABLE TYPE AND NLEVELS TOGETHER BY NAME***;
proc sql;
create table meta as
select name,type,nlevels
from dictionary.columns,nlevelsds
where libname='ANNUITY' and memname='INSURANCE_T' and name=tablevar;
quit;

***DISCRIMINATE BETWEEN CATEGORICAL AND CONTINUOUS VARIABLES***;
proc sql;
title 'Categorical variables to process with PROC FREQ';
select name
from meta
where nlevels <= 10;
title 'Binary variables to process with PROC FREQ';
select name
from meta
where nlevels = 2;
title 'Continuous variables to process with PROC MEANS';
select name
from meta
where nlevels > 10 and type='num';
title;
quit;

***STORE QUERY RESULTS IN MACRO VARIABLES AND OUTPUT TO THE LOG***;
proc sql noprint;
select name into :FREQvars separated by ' '
from meta
where nlevels <= 10;
%put FREQvars=&FREQvars;

select name into :BINvars separated by ' '
from meta
where nlevels = 2;
%put BINvars=&BINvars;

select name into :MEANSvars separated by ' '
from meta
where nlevels > 10 and type='num';
%put MEANSvars=&MEANSvars;

***CREATE A MACRO FOR BANK BRANCH***;
select name into :CHARvars separated by ' '
from meta
where nlevels > 10 and type='char';
%put CHARvars=&CHARvars;
quit;

***PRINT FREQ/MEANS FOR ALL VARIABLES***;
proc freq data=annuity.insurance_t;
tables &FREQvars;
title 'Categorical Variables';
run;

proc freq data=annuity.insurance_t;
tables &BINvars;
title 'Binary Variables';

proc freq data=annuity.insurance_t;
tables &CHARvars;
title 'Categorical Character Variable';
run;
proc means data=annuity.insurance_t;
var &MEANSvars;
title 'Continuous Variables';
run;

title;

***DEFINE CATEGORICAL VARIABLE MACRO***;
%let categorical=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MMCRED MTG
				 CC CCPURC SDB HMOWN MOVED INAREA RES BRANCH;

***DEFINE BINARY VARIABLE MACRO***;
%let binary=DDA DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MTG CC SDB HMOWN MOVED INAREA;

***DEFINE CONTINUOUS VARIABLE MACRO***;
%let continuous=ACCTAGE DDABAL DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT
				CDBAL IRABAL LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE;

proc freq data=annuity.insurance_t;
tables &binary;
run;

proc freq data=annuity.insurance_t;
tables &categorical;
run;

proc means data=annuity.insurance_t;
var &continuous;
run;
