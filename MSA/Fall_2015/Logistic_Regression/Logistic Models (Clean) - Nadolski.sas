libname annuity "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework";

***DEFINE MACRO VARIABLES***

*STRICT BINARY CONTAINING ONLY TWO LEVELS - EXCLUDES: INV CC HMOWN*;
%let binary=DDA DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MTG CC SDB HMOWN MOVED INAREA;

%let ordinal=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MMCRED MTG CC CCPURCH SDB HMOWN MOVED INAREA;

%let nominal=BRANCH RES;

%let categorical=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MMCRED MTG CC CCPURC SDB HMOWN MOVED INAREA RES BRANCH; 

%let sig_cat=DDA DIRDEP NSF SAV ATM CD IRA INV MM MMCRED CC CCPURC SDB INAREA BRANCH;

%let sig_bin=DDA DIRDEP NSF SAV ATM CD IRA INV MM CC SDB INAREA;

%let sig_ord=CCPURC MMCRED;

%let sig_nom=BRANCH;

%let continuous=ACCTAGE DDABAL DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT
				CDBAL IRABAL LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE;

%let log_continuous= L_ACCTAGE L_DDABAL	L_DEP L_DEPAMT L_CHECKS	L_NSFAMT L_PHONE L_TELLER L_SAVBAL L_ATMAMT	L_POS L_POSAMT L_CDBAL
					 L_IRABAL L_LOCBAL	L_INVBAL L_ILSBAL L_MMBAL L_MTGBAL L_CCBAL L_INCOME L_LORES L_HMVAL	L_AGE L_CRSCORE;

%let BT=BT_DEP BT_MMBAL BT_ATMAMT BT_CDBAL BT_SAVBAL;

proc means data=annuity.insurance_t nmiss;
	var &continuous;
run;

***BASIC LOGISTIC MODEL WITH ALL SIGNIFICANT CATEGORICAL VARIABLES***;
proc logistic data=annuity.insurance_t;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm / clodds=pl;
run;

***LOGISTIC MODEL WITH ALL SIGNIFICANT CATEGORICAL VARIABLES & CONTINUOUS VARIABLES***;
proc logistic data=annuity.insurance_t alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &continuous / clodds=pl;
run;

***LOGISTIC MODEL WITH JUST CONTINUOUS VARIABLES (PROVIDES BETA COEFFICIENTS FOR BT TRANSFORM)***;
proc logistic data=annuity.insurance_t alpha=.001;
	model ins (event='1')= &continuous / clodds=pl;
run;

**SHIFT ALL VARIABLES CONTAINING NEGATIVE VALUES UP BY THEIR MINIMUM VALUE (ENSURE MIN VALUE IS ALWAYS 1)***;
data work.insurance;
	set annuity.insurance_t;
	DDABAL=DDABAL+400.53;
	if DDABAL=400.53 then DDABAL=0;
	LOCBAL=LOCBAL+17.4;
	if LOCBAL=17.4 then LOCBAL=0;
	CCBAL=CCBAL+1904.99;
	if CCBAL=1904.99 then CCBAL=0;
run;

proc means data=insurance;
	var &continuous;
run;

***CREATE LOGGED CONTINUOUS VARIABLES FOR BOX-TIDWELL TRANSFORMATION***;
data work.insurance;
	set insurance;
***NEED TO FIRST ADD A ONE TO ALL VALUES TO PREVENT LOG_VAR FROM BEING MISSING WHEN VAR VALUE IS ZERO***;
	L_ACCTAGE=acctage*log(acctage+1);
	L_DDABAL=ddabal*log(ddabal+1);
	L_DEP=dep*log(dep+1);
	L_DEPAMT=depamt*log(depamt+1);
	L_CHECKS=checks*log(checks+1);
	L_NSFAMT=nsfamt*log(nsfamt+1);
	L_PHONE=phone*log(phone+1);
	L_TELLER=teller*log(teller+1);
	L_SAVBAL=savbal*log(savbal+1);
	L_ATMAMT=atmamt*log(atmamt+1);
	L_POS=pos*log(pos+1);
	L_POSAMT=posamt*log(posamt+1);
	L_CDBAL=cdbal*log(cdbal+1);
	L_IRABAL=irabal*log(irabal+1);
	L_LOCBAL=locbal*log(locbal+1);
	L_INVBAL=invbal*log(invbal+1);
	L_ILSBAL=ilsbal*log(ilsbal+1);
	L_MMBAL=mmbal*log(mmbal+1);
	L_MTGBAL=mtgbal*log(mtgbal+1);
	L_CCBAL=ccbal*log(ccbal+1);
	L_INCOME=income*log(income+1);
	L_LORES=lores*log(lores+1);
	L_HMVAL=hmval*log(hmval+1);
	L_AGE=age*log(age+1);
	L_CRSCORE=crscore*log(crscore+1);
run;

***PERFORM BOX TID-WELL TEST OF FUNCTIONAL FORM ON EXPONENTS - 7 SIGNIFICANT NONLINEAR VARIABLES***;
proc logistic data=insurance alpha=.001 plots(only)=(effect(clband showobs) oddsratio);
	model ins (event='1')= &continuous &log_continuous / clodds=pl;
ods output ParameterEstimates=ParameterEstimates;
title 'Box Tid-Well Test of Log-Transformed Coefficients';
run;
title;

***COLLECT PARAMETER ESTIMATES AND P-VALS IN DESCENDING ORDER***;
data parameterestimates;
	set parameterestimates;
	if find(variable,'L_') = 0 then delete;
	drop df stderr waldchisq _esttype_;
run;

proc sort data=parameterestimates;
	by descending probchisq;
run;

proc print data=parameterestimates noobs;
run;

***CREATE BOX-TIDWELL TRANSFORMED POWER VARIABLES (BASED ON MODEL CONTAINING ONLY CONTINUOUS BETA ESTIMATES)***;
data insurance;
	set insurance;
***NEED TO ADD ONE TO EVERY VALUE IN ORDER TO ENABLE RAISING THE VARIABLE TO A NEGATIVE EXPONENT)***;
	BT_DEP=(DEP+1)**(-0.412506857);
	BT_MMBAL=(MMBAL+1)**(-0.37254902);
	BT_ATMAMT=(ATMAMT+1)**(0.523809524);
	BT_CDBAL=(CDBAL+1)**(0.473684211);
	BT_SAVBAL=(SAVBAL+1)**(-0.041666667);
run;

***BT TRANSFORMED MODEL SELECTION - 11 SIG VARIABLES* C=0.796**;
proc logistic data=insurance alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT2_DDABAL=.1 BT2_SAVBAL=.1 BT2_ATMAMT=100 BT2_CDBAL=100 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &continuous &BT / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***BT TRANSFORMED MODEL SELECTION - 11 SIG VARIABLES* C=0.796**;
proc logistic data=insurance alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	units BT_DDABAL=10000000 BT_SAVBAL=100000 BT_ATMAMT=10 BT_CDBAL=10 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &continuous &BT / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***CHECK FOR MISSING VALUES IN REMAINING VARIABLES***;
proc freq data=annuity.insurance_t nlevels;	
	tables &sig_cat;
run;

***ONLY BT_DDABAL HAS SIGNIFICANT MISSING VALUES***;
proc means data=insurance nmiss;
	var &continuous &BT;
run;

***RECLASSIFY MISSING VALUES AS ONE FOR BT_DDABAL***;
data insurance;
	set insurance;
	if BT_DDABAL=. then BT_DDABAL_check=1; else BT_DDABAL_check=0;
run;

***CHECK EACH VARIABLE TO SEE IF MISSING VALUES ARE RANDOM OR IF IT'S WORTH ATTEMPTING TO RECLASSIFY***;
proc logistic data=insurance alpha=.001;
	model ins (event='1')=BT_DDABAL_CHECK / clodds=pl;
run;
***^BT_DDABAL_check IS SIGNIFICANT SO MISSING VALUES ARE NOT RANDOM***;

***COMPARE C-VALUE OF MODEL WITHOUT SIGNIFICANT MISSING VALUE VARIABLE TO EVALUATE IMPACT ON FIT***;

***FULL MODEL - 11 SIGNIFICANT VARIABLES C=0.789***;
proc logistic data=insurance alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT_DDABAL=.1 BT_SAVBAL=.1 BT_ATMAMT=100 BT_CDBAL=100 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &continuous &BT / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***MODEL WITHOUT BT_DDABAL - 13 SIGNIFICANT VARIABLES C=0.777***;
proc logistic data=insurance alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT_SAVBAL=.1 BT_ATMAMT=100 BT_CDBAL=100 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm ACCTAGE DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT
							CDBAL IRABAL LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE BT_ACCTAGE BT_DEP
							BT_SAVBAL BT_ATMAMT BT_CDBAL BT_MMBAL / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***RECLASSIFY MISSING VALUES AS ONE FOR CC, INCOME, HMVAL***;
data insurance;
	set insurance;
	if CC=. then CC_check=1; else CC_check=0;
	if INCOME=. then INCOME_check=1; else INCOME_check=0;
	if HMVAL=. then HMVAL_check=1; else HMVAL_check=0;
run;

***CHECK EACH NEW VARIABLE TO SEE IF MISSING VALUES ARE RANDOM OR IF IT'S WORTH ATTEMPTING TO RECLASSIFY***;

proc logistic data=insurance alpha=.001;
	class cc_check (param=ref ref=first);
	model ins (event='1')=CC_check / clodds=pl;
run;
***^CC_check IS SIGNIFICANT SO MISSING VALUES ARE NOT RANDOM***;

proc logistic data=insurance alpha=.001;
	model ins (event='1')=INCOME_check / clodds=pl;
run;
***^INCOME_check IS NOT SIGNIFICANT SO MISSING VALUES CAN BE IGNORED***;

proc logistic data=insurance alpha=.001;
	model ins (event='1')=HMVAL_check / clodds=pl;
run;
***^HMVAL_check IS NOT SIGNIFICANT SO MISSING VALUES CAN BE IGNORED***;

***NEED TO COMPARE MODEL WITH CC TO MODEL WITHOUT CC AND COMPARE FIT***;

***MODEL WITHOUT CC - 12 SIGNIFICANT VARIABLES C=0.777 (IDENTICAL TO MODEL WITH CC)***;
proc logistic data=insurance alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT_SAVBAL=.1 BT_ATMAMT=100 BT_CDBAL=100 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH DDA DIRDEP NSF SAV ATM CD IRA INV MM SDB INAREA sav*mm ACCTAGE DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT
							CDBAL IRABAL LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE BT_ACCTAGE BT_DEP
							BT_SAVBAL BT_ATMAMT BT_CDBAL BT_MMBAL / clodds=pl SELECTION=BACKWARD slstay=.001;
run;
