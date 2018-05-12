 libname annuity "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework";

***DEFINE MACRO VARIABLES***

*STRICT BINARY CONTAINING ONLY TWO LEVELS - EXCLUDES: INV CC HMOWN*;
%let binary=DDA DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MTG CC SDB HMOWN MOVED INAREA;

%let sig_bin=DDA DIRDEP NSF SAV ATM CD IRA INV MM CC SDB INAREA CCPURC_bin2 MMCRED_bin2;

%let ordinal=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MMCRED MTG CC CCPURCH SDB HMOWN MOVED INAREA;

%let sig_ord=CCPURC_bin2 MMCRED_bin2;

%let nominal=BRANCH RES;

%let categorical=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MTG CC SDB HMOWN MOVED INAREA RES BRANCH; 

%let sig_cat=DDA DIRDEP NSF SAV ATM CD IRA INV MM CC SDB INAREA BRANCH;

%let continuous=ACCTAGE DDABAL DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT
				CDBAL IRABAL LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE;

%let binned1=DDABAL_BIN ACCTAGE_BIN DEPAMT_BIN CHECKS_BIN NSFAMT_BIN PHONE_BIN TELLER_BIN SAVBAL_BIN ATMAMT_BIN POS_BIN POSAMT_BIN
			 CDBAL_BIN IRABAL_BIN LOCBAL_BIN INVBAL_BIN ILSBAL_BIN MMBAL_BIN MTGBAL_BIN CCBAL_BIN INCOME_BIN LORES_BIN HMVAL_BIN
			 AGE_BIN CRSCORE_BIN;

%let collapsed=DDABAL_bin2 DEPAMT_bin2 CHECKS_bin2 SAVBAL_bin2 CDBAL_bin2 IRABAL_bin2 LOCBAL_bin2 INVBAL_bin2 MTGBAL_bin2
			   CCBAL_bin2 HMVAL_bin2 AGE_bin2 CRSCORE_bin2 INCOME_bin2;

%let binned2=DDABAL_BIN2 ACCTAGE_BIN DEPAMT_BIN2 CHECKS_BIN2 NSFAMT_BIN PHONE_BIN TELLER_BIN SAVBAL_BIN2 ATMAMT_BIN POS_BIN POSAMT_BIN
			 CDBAL_BIN2 IRABAL_BIN2 LOCBAL_BIN2 INVBAL_BIN2 ILSBAL_BIN MMBAL_BIN MTGBAL_BIN2 CCBAL_BIN2 INCOME_BIN LORES_BIN HMVAL_BIN2
			 AGE_BIN2 CRSCORE_BIN2 MMCRED_bin2 CCPURC_bin2 INCOME_bin2;

***MMBAL REMOVED SINCE IT WAS A LINEAR COMBINATION OF MM***;
%let sig_variables=DDA DIRDEP NSF SAV ATM CD IRA INV MM CC SDB INAREA BRANCH DDABAL_BIN2 ACCTAGE_BIN DEPAMT_BIN2 CHECKS_BIN2 NSFAMT_BIN
				   PHONE_BIN TELLER_BIN SAVBAL_BIN2 ATMAMT_BIN POS_BIN POSAMT_BIN CDBAL_BIN2 IRABAL_BIN2 LOCBAL_BIN2 INVBAL_BIN2 ILSBAL_BIN
				   MTGBAL_BIN2 CCBAL_BIN2 INCOME_BIN2 LORES_BIN HMVAL_BIN2 AGE_BIN2 CRSCORE_BIN2 MMCRED_bin2 CCPURC_bin2 MMBAL_bin;

%let interaction=ATM CASHBK CC CD DDA DEP DIRDEP HMOWN ILS INAREA INV IRA LOC MM MOVED MTG NSF RES SAV SDB;

%let sig_main=DDA CD IRA INV MM CC BRANCH DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2;

%let int_without_main=ATM CASHBK DEP DIRDEP HMOWN ILS LOC MOVED MTG NSF RES SAV SDB;

***DESCRIPTIVE STATS FOR BINNED VARIABLES***;
proc freq data=annuity.insurance_t_bin nlevels;
	tables &binned1 / plots(only)=freqplot (scale=percent);
run;

***COLLAPSE BINNED VARIABLES***;
data insurance_t_bin;
	set annuity.insurance_t_bin;

	if DDABAL_bin=1 then DDABAL_bin2=1;
	if 2<=DDABAL_bin<=4 then DDABAL_bin2=2;
	if 5<=DDABAL_bin<=7 then DDABAL_bin2=3;
	if DDABAL_bin=8 then DDABAL_bin2=4;

	if DEPAMT_bin<3 then DEPAMT_bin2=1;
	if DEPAMT_bin=3 then DEPAMT_bin2=2;
	if DEPAMT_bin=>4 then DEPAMT_bin2=3;

	if CHECKS_bin=1 then CHECKS_bin2=1;
	if 2<=CHECKS_bin<=3 then CHECKS_bin2=2;
	if CHECKS_bin=4 then CHECKS_bin2=3;
	
	if SAVBAL_bin=1 then SAVBAL_bin2=1;
	if 2<=SAVBAL_bin<=3 then SAVBAL_bin2=2;
	if SAVBAL_bin=4 then SAVBAL_bin2=3;
	if 5<=SAVBAL_bin<=6 then SAVBAL_bin2=4;
	if SAVBAL_bin=7 then SAVBAL_bin2=5;

	if CDBAL_bin<3 then CDBAL_bin2=1;
	if CDBAL_bin=3 then CDBAL_bin2=2;

	if IRABAL=0 then IRABAL_bin2=1;
	if IRABAL>0 then IRABAL_bin2=2;

	if LOCBAL<=0 then LOCBAL_bin2=1;
	if LOCBAL>0 then LOCBAL_bin2=2;

	if INVBAL=0 then INVBAL_bin2=1;
	if INVBAL>0 then INVBAL_bin2=2;

	if MTGBAL=0 then MTGBAL_bin2=1;
	if MTGBAL>0 then MTGBAL_bin2=2;

	*if CCBAL=. then CCBAL_bin2=1;
	if -2000<=CCBAL<0 then CCBAL_bin2=2;
	if CCBAL=0 then CCBAL_bin2=3;
	if CCBAL>0 then CCBAL_bin2=4;

	if HMVAL_bin=1 then HMVAL_bin2=1;
	if HMVAL_bin=2 then HMVAL_bin2=2;
	if HMVAL_bin=4 then HMVAL_bin2=3;
	if HMVAL_bin=5 then HMVAL_bin2=4;

	if AGE_bin<=3 then AGE_bin2=1;
	if AGE_bin=4 then AGE_bin2=2;

	if 1<=CRSCORE_bin<=2 then CRSCORE_bin2=1;
	if 3<=CRSCORE_bin<=4 then CRSCORE_bin2=2;

	if MMCRED=0 then MMCRED_bin2=0;
	if MMCRED>0 then MMCRED_bin2=1;

	if CCPURC=0 then CCPURC_bin2=0;
	if CCPURC>0 then CCPURC_bin2=1;
	*if CCPURC=. then CCPURC_bin2=2;

	if INCOME_bin<=2 then INCOME_bin2=1;
	if INCOME_bin=3 then INCOME_bin2=2;

	if CC=0 then CC2=0;
	if CC=1 then CC2=1;
	*if CC=. then CC2=2;
		
run; 

proc freq data=insurance_t_bin;
	tables &sig_variables;
run;

***CREATE FORMATS FOR COLLAPSED VARIABLES***;
proc format;
	value acctageformat
		3='Missing'
		2='Old (20.1-56.3)'
		1='Young (0.3-20)';
	value ddabalformat
		1='Negative'
		2='Low (1-750)'
		3='Medium (750-6,000)'
		4='High (>6,000)';
	value depamtformat
		1='Low (0-700)'
		2='Medium (700-2200)'
		3='High (2200-485,000)';
	value savbalformat
		1='None'
		2='Low (.01-250)'
		3='Medium (250-1250)'
		4='Mid High (1253-7973)'
		5='High (>8060)';
	value locbalformat
		1='Negative or Zero'
		2='Positive';
	value mtgvalformat
		1='Zero'
		2='Positive';
	value ccbalformat
		1='Missing'
		2='Negative'
		3='Zero'
		4='Positive';
	value hmvalformat
		1='Low (69-100K)'
		2='Medium (101-125K)'
		3='High (126-625K)'
		4='Missing';
	value ageformat
		1='Young (16-45)'
		2='Old (46-94)';
	value crscoreformat
		1='Low (509-650)'
		2='High (651-807)';	
	value mmcredformat
		0='Zero'
		1='Positive';
	value ccpurcformat
		0='Zero'
		1='Positive';
	value incomeformat
		1='Less than $100K'
		2='More than $100K';	
run;


***CHECK FOR SEPARATION OF MAIN EFFECTS WITH INS - NO CELL COUNTS ZERO SO NOT AN ISSUE FOR MAIN EFFECTS***;
proc freq data=insurance_t_bin nlevels;
	tables INS*(&binned2) / plots(only)=freqplot (scale=percent);
run;

***FORWARD SELECTION C=0.796***;
proc logistic data=insurance_t_bin alpha=.001;
	class &sig_variables / param=ref ref=first;
	model ins (event='1')= &sig_variables / clodds=pl SELECTION=FORWARD slentry=.001;
run;

***BACKWARD SELECTION C=0.796 - DDA ESTIMATE IS FLIPPED COMPARED TO FORWARD & STEPWISE***;
proc logistic data=insurance_t_bin alpha=.001;
	class &sig_variables / param=ref ref=last;
	model ins (event='1')= &sig_variables / clodds=pl SELECTION=BACKWARD slstay=.001;
run;

***STEPWISE SELECTION FOR ALL VARIABLES C=0.796 ***;
proc logistic data=insurance_t_bin alpha=.001;
	class &sig_variables / param=ref ref=first;
	model ins (event='1')= &sig_variables / clodds=pl SELECTION=STEPWISE slstay=.001 slentry=.001;
run;

***MODIFIED FORWARD SELECTION WITH INTERACTIONS - SAME AS ABOVE C=0.796***;
proc logistic data=insurance_t_bin alpha=.001;
	class &sig_variables / param=ref ref=first;
	model ins (event='1')= &sig_variables &sig_variables|&sig_variables @2
			/ include=12 clodds=pl SELECTION=STEPWISE slentry=.001 slstay=.001;
run;

proc freq data=insurance_t_bin nlevels;
	tables &sig_variables;
run;

***CHECK FOR SIGNIFICANCE OF VARIABLES WITHOUT MISSING OBSERVATIONS - BRANCH SIGNIFICANT ***;
proc logistic data=insurance_t_bin alpha=.001;
	class DDA DIRDEP NSF SAV ATM CD IRA MM SDB INAREA BRANCH DDABAL_BIN2 ACCTAGE_BIN DEPAMT_BIN2 CHECKS_BIN2 NSFAMT_BIN
				   PHONE_BIN TELLER_BIN SAVBAL_BIN2 ATMAMT_BIN POS_BIN POSAMT_BIN CDBAL_BIN2 IRABAL_BIN2 LOCBAL_BIN2 ILSBAL_BIN
				   MTGBAL_BIN2 INCOME_BIN2 LORES_BIN AGE_BIN2 CRSCORE_BIN2 MMCRED_bin2 MMBAL_bin / param=ref ref=first;
	model ins (event='1')= DDA DIRDEP NSF SAV ATM CD IRA MM SDB INAREA BRANCH DDABAL_BIN2 ACCTAGE_BIN DEPAMT_BIN2 CHECKS_BIN2 NSFAMT_BIN
				   PHONE_BIN TELLER_BIN SAVBAL_BIN2 ATMAMT_BIN POS_BIN POSAMT_BIN CDBAL_BIN2 IRABAL_BIN2 LOCBAL_BIN2 ILSBAL_BIN
				   MTGBAL_BIN2 INCOME_BIN2 LORES_BIN AGE_BIN2 CRSCORE_BIN2 MMCRED_bin2 MMBAL_bin / clodds=pl SELECTION=STEPWISE slstay=.001 slentry=.001;
run;

***MAIN EFFECTS MODEL WITH ALL PREVIOUSLY SIGNIFICANT VARIABLES PLUS BRANCH***;
proc logistic data=insurance_t_bin alpha=.001;
	class DDA CD IRA INV MM CC BRANCH DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2 / param=ref ref=first;
	model ins (event='1')= DDA CD IRA INV MM CC BRANCH DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2 / clodds=pl;
run;

***MODIFIED FORWARD SELECTION WITH INTERACTIONS - SAME AS ABOVE C=0.796***;
proc logistic data=insurance_t_bin alpha=.001;
	class &sig_main &int_without_main / param=ref ref=first;
	model ins (event='1')= &sig_main &int_without_main &sig_main|&int_without_main @2
			/ include=13 clodds=pl SELECTION=STEPWISE slentry=.001 slstay=.001;
run;

***LEVERAGE DIAGNOSTIC PLOTS - WARNING: TAKES A LONG TIME TO COMPUTE***;
proc logistic data=insurance_t_bin plots(only label maxpoints=none)=(leverage dfbetas dpc influence phat) alpha=.001;
	class &sig_variables &interaction / param=ref ref=first;
	model ins (event='1')= DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2
							&sig_variables|&interaction @2 / include=12 clodds=pl SELECTION=FORWARD slentry=.001;
	output out=predict p=pred;
run;


***COMPARE ROC CURVES***;
proc logistic data=insurance_t_bin alpha=.001;
	class DDA CD IRA INV MM CC BRANCH DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2 / param=ref ref=first;
	model ins (event='1')= DDA CD IRA INV MM CC BRANCH DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2 / clodds=pl;
	ROC 'Omit BRANCH' DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2;
	ROC 'Omit CC' DDA CD IRA INV MM BRANCH DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2;
	ROC 'Omit CC & BRANCH' DDA CD IRA INV MM DDABAL_bin2 CHECKS_bin2 TELLER_Bin SAVBAL_bin2 ATMAMT_Bin CDBAL_bin2;
	ROCcontrast / estimate=allpairs;
	title 'Comparing ROC Curves';
run;


***CREATE ROC CURVE & CLASSIFICATION TABLE***;
ods graphics on;
proc logistic data=insurance_t_bin alpha=.001;
	class DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2 / param=ref ref=first;
	model ins (event='1')= DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2
								/ clodds=pl outroc=ROC;
run;

***CREATE YOUDEN INDEX***;
data Youden;
	set Roc;
	_spec_=1-_1mspec_;
	J=_sensit_+_spec_-1;
run;

***IDENTIFY OPTIMAL CUTOFF BASED ON YOUDENS J***;
proc sql;
	select _prob_, J
	from Youden
	order J desc;
quit;

***CREATE CLASSIFICATION TABLE BASED ON OPTIMAL CUTOFF***;
proc logistic data=insurance_t_bin alpha=.001;
	class DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2 / param=ref ref=first;
	model ins (event='1')= DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2
								/ clodds=pl outroc=ROC ctable pprob=0.316893;
run;

***EXAMINE CLASSIFICATION RATE TABLE FOR ALL CUTOFFS - 0.415 BEATS YOUDEN J CUTOFF (73.8% SUCCESS RATE VS. 72.1%)***;
proc logistic data=insurance_t_bin alpha=.001;
	class DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2 / param=ref ref=first;
	model ins (event='1')= DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2
								/ clodds=pl ctable pprob=0 to .99 by .005;
run;


*===============================TEST AGAINST VALIDATION DATA===============================================================*;

***COLLAPSE BINNED VARIABLES FOR VALIDATION DATASET***;
data insurance_v_bin;
	set annuity.insurance_v_bin;

	if DDABAL_bin=1 then DDABAL_bin2=1;
	if 2<=DDABAL_bin<=4 then DDABAL_bin2=2;
	if 5<=DDABAL_bin<=7 then DDABAL_bin2=3;
	if DDABAL_bin=8 then DDABAL_bin2=4;

	if DEPAMT_bin<3 then DEPAMT_bin2=1;
	if DEPAMT_bin=3 then DEPAMT_bin2=2;
	if DEPAMT_bin=>4 then DEPAMT_bin2=3;

	if CHECKS_bin=1 then CHECKS_bin2=1;
	if 2<=CHECKS_bin<=3 then CHECKS_bin2=2;
	if CHECKS_bin=4 then CHECKS_bin2=3;
	
	if SAVBAL_bin=1 then SAVBAL_bin2=1;
	if 2<=SAVBAL_bin<=3 then SAVBAL_bin2=2;
	if SAVBAL_bin=4 then SAVBAL_bin2=3;
	if 5<=SAVBAL_bin<=6 then SAVBAL_bin2=4;
	if SAVBAL_bin=7 then SAVBAL_bin2=5;

	if CDBAL_bin<3 then CDBAL_bin2=1;
	if CDBAL_bin=3 then CDBAL_bin2=2;

	if IRABAL=0 then IRABAL_bin2=1;
	if IRABAL>0 then IRABAL_bin2=2;

	if LOCBAL<=0 then LOCBAL_bin2=1;
	if LOCBAL>0 then LOCBAL_bin2=2;

	if INVBAL=0 then INVBAL_bin2=1;
	if INVBAL>0 then INVBAL_bin2=2;

	if MTGBAL=0 then MTGBAL_bin2=1;
	if MTGBAL>0 then MTGBAL_bin2=2;

	*if CCBAL=. then CCBAL_bin2=1;
	if -2000<=CCBAL<0 then CCBAL_bin2=2;
	if CCBAL=0 then CCBAL_bin2=3;
	if CCBAL>0 then CCBAL_bin2=4;

	if HMVAL_bin=1 then HMVAL_bin2=1;
	if HMVAL_bin=2 then HMVAL_bin2=2;
	if HMVAL_bin=4 then HMVAL_bin2=3;
	if HMVAL_bin=5 then HMVAL_bin2=4;

	if AGE_bin<=3 then AGE_bin2=1;
	if AGE_bin=4 then AGE_bin2=2;

	if 1<=CRSCORE_bin<=2 then CRSCORE_bin2=1;
	if 3<=CRSCORE_bin<=4 then CRSCORE_bin2=2;

	if MMCRED=0 then MMCRED_bin2=0;
	if MMCRED>0 then MMCRED_bin2=1;

	if CCPURC=0 then CCPURC_bin2=0;
	if CCPURC>0 then CCPURC_bin2=1;
	*if CCPURC=. then CCPURC_bin2=2;

	if INCOME_bin<=2 then INCOME_bin2=1;
	if INCOME_bin=3 then INCOME_bin2=2;

	if CC=0 then CC2=0;
	if CC=1 then CC2=1;
	*if CC=. then CC2=2;
		
run; 

***SCORE DATA ON VALIDATION SET***;
proc logistic data=insurance_t_bin alpha=.001;
	class DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2 / param=ref ref=first;
	model ins (event='1')= DDA CD IRA INV MM CC DDABAL_bin2 CHECKS_bin2 TELLER_bin SAVBAL_bin2 ATMAMT_bin CDBAL_bin2 / pprob=0.415;
	score data=insurance_v_bin out=insurance_scored;
run;
	
data insurance_scored;
	set insurance_scored;
	if P_1 > 0.415 then Predicted = 1; else Predicted = 0;
run;

proc freq data=insurance_scored;
	tables INS*Predicted / nocol nopercent norow;
run;
quit;
