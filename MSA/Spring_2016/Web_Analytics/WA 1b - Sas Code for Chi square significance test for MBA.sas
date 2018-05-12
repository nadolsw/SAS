*\\Set macro variable transN to total number of market baskets (or transactions);

PROC SQL noprint;
	select count(distinct(%EM_ID))
	into :transN
	from &EM_IMPORT_TRANSACTION
	;
QUIT;

*\\Create dataset that will add Chi Square statistic to existing Rules;

DATA work.ChiSquare;
	*\\Start with Association Node Rules output table;
	SET &EM_IMPORT_RULES;

	*\\Add Chi Square Statistic to each rule;
	CHISQ = .; *CHISQ will be missing in case of divide by zero scenario;
	PVALUE = .;
	if NOT (CONF=SUPPORT or LIFT=CONF) then do;
		CHISQ = (&transN * (LIFT-1)**2) * ((SUPPORT/100) * (CONF/100) /
				((CONF/100 - SUPPORT/100) * (LIFT - CONF/100));
		PVALUE = 1-Probchi(CHISQ,1);
	END;

	*\\Keep desired columns;
	KEEP index rule exp_conf conf support lift chisq pvalue;
RUN;

PROC SORT Data= work.ChiSquare;
	by descending lift;
RUN;

PROC PRINT;
RUN;

*\\The chisquare table is currently in teh temporary work library; 
*\\The following code saves the table to your PROJECT LIBRARY;
* DATA  <yourprjlibname>.ChiSquare;
* SET work.ChiSquare;
* RUN;
