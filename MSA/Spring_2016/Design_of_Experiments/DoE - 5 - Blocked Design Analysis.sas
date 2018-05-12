
*******/ANALYSIS OF BLOCKED DESIGN/*******;

ODS SELECT globalTests type3;
TITLE "Fit model for Response to blocked factorial experiment";
PROC LOGISTIC Data=blockdata1;
	CLASS interestrate sticker pricegraphic riskgrp;
	MODEL response(event="1")=interestrate|sticker|pricegraphic|riskgrp;
	FREQ frequency; 
RUN; 

*/Removing the four-way interaction/*;
ODS SELECT globalTests type3;
TITLE "Fit model for Response to blocked factorial experiment";
PROC LOGISTIC Data=blockdata1;
	CLASS interestrate sticker pricegraphic riskgrp;
	MODEL response(event="1")=interestrate|sticker|pricegraphic|riskgrp @1
	interestrate|sticker|pricegraphic|riskgrp @2
	interestrate|sticker|pricegraphic|riskgrp @3;
	FREQ frequency; 
RUN; 

*/Removing the three-way interactions, and interactions of block and factors/*;

ODS SELECT globalTests type3;
TITLE "Fit model for Response to blocked factorial experiment";
PROC LOGISTIC Data=blockdata1;
	CLASS interestrate sticker pricegraphic riskgrp;
	MODEL response(event="1")=interestrate|sticker|pricegraphic|riskgrp @1
	interestrate|sticker|pricegraphic @2/;
	FREQ frequency;
	OUTPUT out=work.trt p=p;
RUN; 

DATA work.response;
SET work.trt;
if response="0" then delete;
RUN;

PROC means data=work.response mean;
	CLASS interestRate sticker pricegraphic riskgrp;
	VAR p;
RUN;

	


