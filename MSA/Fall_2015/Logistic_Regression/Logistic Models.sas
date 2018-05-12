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

%let sig_backward=DDA SAV CD IRA MM CC DDABAL CHECKS PHONE TELLER SAVBAL ATMAMT MMBAL;

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

***PERFORM BACKWARDS SELECTION ON FULL MODEL***;
proc logistic data=annuity.insurance_t alpha=.001;
	class CCPURC (param=ref ref=last) MMCRED (param=ref ref=last) BRANCH (param=ref ref='B17')
			&sig_bin / param=ref ref=first;
	units DDABAL=1000 SAVBAL=1000 ATMAMT=1000 MMBAL=1000;
	model ins (event='1')= &sig_ord BRANCH &sig_bin sav*mm &continuous / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***CHECK FOR MISSING VALUES IN REMAINING VARIABLES***;
proc freq data=annuity.insurance_t nlevels;
	tables &categorical;
run;

proc means data=annuity.insurance_t nmiss;
	var &continuous;
run;
