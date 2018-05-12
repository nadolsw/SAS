******/ANALYZING A 2 BY 2 FACTORIAL EXPERIMENT WITH INTERACTION/******;

PROC SGPLOT Data=introgotodata1(where=(response=1));
   SERIES y=frequency x=intro / group=goto;
   TITLE "Response=1";
run;

ODS SELECT globalTests type3;
TITLE "Fit model for Response to 2x2 factorial experiment";
PROC LOGISTIC Data=introgotodata1;
	CLASS intro goto;
	MODEL response(event="1")=intro|goto;
	FREQ frequency; 
RUN; 

PROC GENMOD Data=introgotodata1 Descending;
	CLASS intro goto;
	MODEL response=intro|goto/dist=bin link=logit;
	LSMEANS intro|goto/DIFF;
	FREQ frequency;
RUN; 

*******/ANALYZING A 2 BY 2 FACTORIAL EXPERIMENT WITH NO INTERACTION/********;

PROC SGPLOT Data=introgotodata2(where=(response=1));
   SERIES y=frequency x=intro / group=goto;
   TITLE "Response=1";
run;

ODS SELECT globalTests type3;
TITLE "Fit model for Response to 2x2 factorial experiment";
PROC LOGISTIC Data=introgotodata2;
	CLASS intro goto;
	MODEL response(event="1")=intro|goto;
	FREQ frequency; 
RUN; 
