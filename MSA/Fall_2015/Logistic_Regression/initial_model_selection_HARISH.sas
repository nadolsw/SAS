LIBNAME annuity 'D:\Data\AA502\BR';

  /* Creating new dataset from the original dataset */
/*ods html close;*/
/*ods pdf file=HW1_Report.pdf;*/

%let sig_cat=DDA DIRDEP NSF SAV ATM CD IRA INV MM MMCRED CC CCPURC SDB INAREA BRANCH;

* dont include MMCRED, CCPURC, BRANCH, All Binned Variables for interaction;

* DDA|DIRDEP|NSF|SAV|ATM|CD|IRA|INV|MM|CC|SDB|INAREA;

%let binned=DDABAL_Bin ACCTAGE_Bin DEPAMT_Bin CHECKS_Bin NSFAMT_Bin PHONE_Bin TELLER_Bin
			SAVBAL_Bin ATMAMT_Bin POS_Bin POSAMT_Bin CDBAL_Bin IRABAL_Bin LOCBAL_Bin
			INVBAL_Bin ILSBAL_Bin MMBAL_Bin MTGBAL_Bin CCBAL_Bin INCOME_Bin LORES_Bin
			HMVAL_Bin AGE_Bin CRSCORE_Bin;

data annuity.insurance3hw;
	set annuity.insurance_t_bin (keep=INS &sig_cat &binned);
run;

*************INITIAL MODEL FIT WITH ALL VARIABLES**************************;

*****STEPWISE SELECTION*************************************************;
proc logistic data=annuity.insurance3hw; 
	CLASS &sig_cat (param=ref ref=last) &binned (param=ref ref=last);
	model INS(event='1') = &sig_cat &binned DDA|DIRDEP|NSF|SAV|ATM|CD|IRA|INV|MM|CC|SDB|INAREA @2
							/ selection=STEPWISE slstay=0.001 clodds=pl;
	ods output ParameterEstimates=est_step;
	title 'Annuity Insurance Purchase Model- Stepwise Subset'; 
run;

proc logistic data=annuity.insurance3hw; 
	CLASS &sig_cat (param=ref ref=last) &binned (param=ref ref=last);
	model INS(event='1') = DDA|DIRDEP|NSF|SAV|ATM|CD|IRA|INV|MM|CC|SDB|INAREA @2
							/ selection=STEPWISE slstay=0.001 clodds=pl;
	ods output ParameterEstimates=est_step;
	title 'Annuity Insurance Purchase Model- Stepwise Subset'; 
run;
*****BACKWARD SELECTION*************************************************;
proc logistic data=annuity.insurance3hw; 
	CLASS &sig_cat (param=ref ref=last);
	model INS(event='1') = &sig_cat &binned 
							DDA|DIRDEP|NSF|SAV|ATM|CD|IRA|INV|MM|CC|SDB|INAREA @2
							/ selection=BACKWARD SLSTAY=0.001;
	ods output ParameterEstimates=est_back;
	title 'Annuity Insurance Purchase Model- Backward Selection'; 
run;
*****FORWARD SELECTION*************************************************;
proc logistic data=annuity.insurance3hw; 
	CLASS &sig_cat (param=ref ref=last);
	model INS(event='1') = &sig_cat &binned
							DDA|DIRDEP|NSF|SAV|ATM|CD|IRA|INV|MM|CC|SDB|INAREA @2
							/ selection=FORWARD SLENTRY=0.001;
	ods output ParameterEstimates=est_fwd;
	title 'Annuity Insurance Purchase Model- Forward Selection'; 
run;

