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

%let non_BT_continuous=DEPAMT CHECKS NSFAMT PHONE TELLER POS POSAMT IRABAL LOCBAL INVBAL ILSBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE;

%let BT2=BT2_ACCTAGE BT2_DDABAL	BT2_DEP	BT2_SAVBAL BT2_ATMAMT BT2_CDBAL	BT2_MMBAL;

%let sig_backward=DDA SAV CD ATM IRA MM CHECKS TELLER BT2_DDABAL BT2_SAVBAL BT2_ATMAMT BT2_CDBAL;

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

***LOGISTIC MODEL WITH JUST CONTINUOUS VARIABLES***;
proc logistic data=annuity.insurance_t alpha=.001;
	model ins (event='1')= &continuous / clodds=pl;
run;

***CREATE LOGGED CONTINUOUS VARIABLES FOR BOX-TIDWELL TRANSFORMATION***;
data insurance_t;
	set annuity.insurance_t;
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

***PERFORM BOX TID-WELL TEST OF FUNCTIONAL FORM ON EXPONENTS***;
proc logistic data=insurance_t alpha=.001 plots(only)=(effect(clband showobs) oddsratio);
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

proc print data=parameterestimates;
run;

***CREATE BOX-TIDWELL TRANSFORMED POWER VARIABLES (BASED ON MODEL CONTAINING ONLY CONTINUOUS BETA ESTIMATES)***;
data annuity.insurance_t;
	set annuity.insurance_t;
	BT2_ACCTAGE=(ACCTAGE+1)**(-5.606822262);
	BT2_DDABAL=(DDABAL+1)**(0.047619048);
	BT2_DEP=(DEP+1)**(-0.359297861);
	BT2_SAVBAL=(SAVBAL+1)**(-0.25);
	BT2_ATMAMT=(ATMAMT+1)**(0.523809524);
	BT2_CDBAL=(CDBAL+1)**(0.473684211);
	BT2_MMBAL=(MMBAL+1)**(-0.37254902);
run;

***TRANSFORMED MODEL BASED ON MODEL CONTAINING ONLY CONTINUOUS BETA ESTIMATES C=0.789***;
proc logistic data=annuity.insurance_t alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT2_DDABAL=.1 BT2_SAVBAL=.1 BT2_ATMAMT=100 BT2_CDBAL=100 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &non_BT_continuous &BT2 / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***CHECK FOR MISSING VALUES IN REMAINING VARIABLES***;
proc freq data=annuity.insurance_t nlevels;
	tables &sig_cat;
run;

proc means data=annuity.insurance_t nmiss;
	var &continuous &BT1 &BT2;
run;

***RECLASSIFY MISSING VALUES AS ONE FOR BT2_ACCTAGE & BT2_DDABAL***;
data insurance;
	set annuity.insurance_t;
	if BT2_ACCTAGE=. then BT2_ACCTAGE_check=1; else BT2_ACCTAGE_check=0;
	if BT2_DDABAL=. then BT2_DDABAL_check=1; else BT2_DDABAL_check=0;
run;

***CHECK EACH VARIABLE TO SEE IF IT'S WORTH ATTEMPTING TO RECLASSIFY***;

proc logistic data=insurance alpha=.001;
	model ins (event='1')=BT2_ACCTAGE_check / clodds=pl;
run;
***^BT2_ACCTAGE_CHECK NOT SIGNIFICANT***;

proc logistic data=insurance alpha=.001;
	model ins (event='1')=BT2_DDABAL_check / clodds=pl;
run;
***^BT2_DDABAL_CHECK IS SIGNIFICANT***;

***COMPARE C-VALUE OF MODEL WITHOUT SIGNIFICANT MISSING VALUE VARIABLES TO EVALUATE IMPACT***;

***FULL MODEL C=0.789***;
proc logistic data=annuity.insurance_t alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT2_DDABAL=.1 BT2_SAVBAL=.1 BT2_ATMAMT=100 BT2_CDBAL=100 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &non_BT_continuous &BT2 / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***MODEL WITHOUT BT2_DDABAL C=0.777***;
proc logistic data=annuity.insurance_t alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	*units BT2_SAVBAL=.1 BT2_ATMAMT=100 BT2_CDBAL=100 CHECKS=1 TELLER=1;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &non_BT_continuous BT2_ACCTAGE BT2_DEP BT2_SAVBAL BT2_ATMAMT BT2_CDBAL BT2_MMBAL / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

