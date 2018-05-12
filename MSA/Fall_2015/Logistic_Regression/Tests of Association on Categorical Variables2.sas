libname annuity "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework";

***DEFINE MACRO VARIABLES***

*STRICT BINARY CONTAINING ONLY TWO LEVELS - EXCLUDES: INV CC HMOWN*;
%let binary=DDA DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MTG CC SDB HMOWN MOVED INAREA;

%let ordinal=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MMCRED MTG CC CCPURCH SDB HMOWN MOVED INAREA;

%let nominal=BRANCH RES;

%let categorical=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MMCRED MTG CC CCPURC SDB HMOWN MOVED INAREA RES BRANCH; 

%let continuous=ACCTAGE DDABAL DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT
				CDBAL IRABAL LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE;

***PERFORM PEARSON CHI-SQUARED TEST ON ALL CATEGORICAL VARIABLES***;
proc freq data=annuity.insurance_t;
	tables (&categorical)*ins / chisq cellchi2 expected relrisk nocol nopercent measures cl;
	title 'Chi-Squared Test of Associations with INS';
run;

title;

***PERFORM EXACT TESTS ON CASHBK & CCPURC***;
proc freq data=annuity.insurance_t;
	tables cashbk*ins ccpurc*ins / chisq cellchi2 expected fisher relrisk nocol nopercent measures cl;
	title 'Chi-Squared Test of Associations with INS';
run;

***PERFORM MANTEL-HAENSZEL ON INS & SAVINGS ACCOUNT***;
proc freq data=annuity.insurance_t nlevels;
	tables sav*ins / chisq expected relrisk nocol nopercent measures cl;
	title 'Chi-Squared Test of SAV Association with INS';
run;

***PERFORM MANTEL-HAENSZEL ON INS & MONEY MARKET ACCOUNT***;
proc freq data=annuity.insurance_t nlevels;
	tables mm*ins / chisq expected relrisk nocol nopercent measures cl;
	title 'Chi-Squared Test of MM Association with INS';
run;

***PERFORM MANTEL-HAENSZEL ON SAVINGS & MONEY MARKET ACCOUNT TO CHECK FOR COLINEARITY***;
proc freq data=annuity.insurance_t nlevels;
	tables sav*mm / chisq expected relrisk nocol nopercent measures cl;
	title 'Chi-Squared Test of SAV & MM';
run;

***PERFORM COCHRANE MANTEL-HAENSZEL & BRESLOW DAY ON INS & SAVINGS ACCOUNT USING MM AS CONFOUNDING WITH 95% CONFIDENCE INTERVAL***;
proc freq data=annuity.insurance_t;
	tables mm*sav*ins / all cmh cl bdt;
	title 'Chi-Squared Test of Potential Confounding MM';
run;

***PERFORM COCHRANE MANTEL-HAENSZEL & BRESLOW DAY ON INS & SAVINGS ACCOUNT USING MM AS CONFOUNDING WITH APLHA = .001***;
proc freq data=annuity.insurance_t;
	tables mm*sav*ins / all cmh cl bdt alpha=.001;
	title 'Chi-Squared Test of Potential Confounding MM';
run;
