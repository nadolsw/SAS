libname annuity "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework";

***DEFINE MACRO VARIABLES***;
%let categorical=DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MMCRED MTG
				 CC CCPURC SDB HMOWN MOVED INAREA RES BRANCH;

*STRICT BINARY CONTAINING ONLY TWO LEVELS - EXCLUDES: INV CC HMOWN*;
%let binary=DDA DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MTG CC SDB HMOWN MOVED INAREA;

%let continuous=ACCTAGE DDABAL DEP DEPAMT CHECKS NSFAMT PHONE TELLER SAVBAL ATMAMT POS POSAMT
				CDBAL IRABAL LOCBAL INVBAL ILSBAL MMBAL MTGBAL CCBAL INCOME LORES HMVAL AGE CRSCORE;

proc freq data=annuity.insurance_t;
tables &categorical / plots=freqplot;
run;

/* MACRO for Box Plots on all Categorical Variables from summer AMES example */
%macro box(dsn      = ,
           response = ,
           Charvar  = );
%let i = 1 ;
%do %while(%scan(&charvar,&i,%str( )) ^= %str()) ;

    %let var = %scan(&charvar,&i,%str( ));

    proc sgplot data=&dsn;
        vbox &response / category=&var 
                         grouporder=ascending 
                         connect=mean;
        title "&response across Levels of &var";
    run;

    %let i = %eval(&i + 1 ) ;
%end ;
%mend box;

%box(dsn      = annuity.insurance_t,
     response = ins,
     charvar  = &categorical);
