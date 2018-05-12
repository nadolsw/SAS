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

%let BT=BT_DDABAL BT_DEP BT_MMBAL BT_ATMAMT BT_CDBAL BT_SAVBAL;

***LOGISTIC MODEL WITH JUST CONTINUOUS VARIABLES (PROVIDES BETA COEFFICIENTS FOR BT TRANSFORM)***;
proc logistic data=annuity.insurance_t alpha=.001;
	model ins (event='1')= &continuous / clodds=pl;
run;

**SHIFT ALL VARIABLES CONTAINING NEGATIVE VALUES UP BY THEIR MINIMUM VALUE (ENSURE MIN VALUE IS ALWAYS 1)***;
data work.insurance;
	set annuity.insurance_t;
	DDABAL=DDABAL+400.53;
	LOCBAL=LOCBAL+17.4;
	CCBAL=CCBAL+1904.99;
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

***PERFORM BOX TID-WELL TEST OF FUNCTIONAL FORM ON EXPONENTS - 6 SIGNIFICANT NONLINEAR VARIABLES***;
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

***CREATE BOX-TIDWELL TRANSFORMED POWER VARIABLES***;
data insurance;
	set insurance;
***NEED TO ADD ONE TO EVERY VALUE IN ORDER TO ENABLE RAISING THE VARIABLE TO A NEGATIVE EXPONENT)***;
	BT_DDABAL=(DDABAL+1)**(-0.19047619);
	BT_DEP=(DEP+1)**(-0.362589139);
	BT_MMBAL=(MMBAL+1)**(-0.37254902);
	BT_ATMAMT=(ATMAMT+1)**(0.523809524);
	BT_CDBAL=(CDBAL+1)**(0.473684211);
	BT_SAVBAL=(SAVBAL+1)**(-0.041666667);
run;

***BT TRANSFORMED MODEL SELECTION - 11 SIG VARIABLES* C=0.796**;
proc logistic data=insurance alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT_DDABAL=10000000 BT_SAVBAL=100000 BT_ATMAMT=10 BT_CDBAL=10 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm BT_DDABAL BT_DEP BT_MMBAL BT_ATMAMT BT_CDBAL BT_SAVBAL 
							ACCTAGE DDABAL DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT CDBAL IRABAL
							LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE/ clodds=pl SELECTION=BACKWARD slstay=.001;
run;

**CHECK FOR MISSING VALUES IN REMAINING VARIABLES***;
proc freq data=annuity.insurance_t nlevels;	
	tables &sig_cat;
run;

***NO SIGNIFICANT VARIABLES HAVE MISSING VALUES***;
proc means data=insurance nmiss;
	var &continuous &BT;
run;
