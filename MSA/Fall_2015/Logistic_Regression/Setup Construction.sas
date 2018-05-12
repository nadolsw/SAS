libname const "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework\Data";

***CONVERT WIN_BID TO BINARY WINNING_BID***;
data const.construction;
	set const.construction;
	if win_bid='No' then winning_bid=0;
	else if win_bid='Yes' then winning_bid=1;
	drop win_bid;
run;

%let categorical=SECTOR REGION_OF_COUNTRY COMPETITOR_A--COMPETITOR_J WINNING_BID;

%let binary=WINNING_BID COMPETITOR_A--COMPETITOR_J;

%let continuous=ESTIMATED_COST__MILLIONS_ ESTIMATED_YEARS_TO_COMPLETE BID_PRICE__MILLIONS_
				NUMBER_OF_COMPETITOR_BIDS WINNING_BID_PRICE__MILLIONS_ COST_AFTER_ENGINEERING_ESTIMATE;

***EXAMINE TO SEE IF ANY MISSING VALUES***;
proc freq data=const.construction nlevels;
	tables &categorical;
run;

proc means data=const.construction n nmiss mean std min max;
	var &continuous;
run;
