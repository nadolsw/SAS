libname project "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework\Data";

***CALCULATE PROFIT MARGIN & ENSURE MINIMUM OF COMPETITORS IS NOT ZERO***;
data construction_t;
	set project.construction_t;
	PROFIT_MARGIN=100*EST_PROFIT/BID_PRICE;
run;

%let continuous=COST_EST EST_TIME BID_PRICE COMPETITORS WINNING_PRICE COST_ENG EST_PROFIT PROFIT_MARGIN;

%let continuous2=COST_EST EST_TIME BID_PRICE COMPETITORS WINNING_PRICE COST_ENG EST_PROFIT;

%let categorical=SECTOR REGION COMPA--COMPJ;

%let categorical2=COMPA COMPB COMPC COMPD COMPE COMPF COMPG COMPH COMPI COMPJ;

%let binned=cost_est_bin est_time_bin profit_margin_bin competitors_bin;

%let vars=COMPB COMPE COMPF COMPH COMPJ SECTOR REGION cost_est_bin est_time_bin profit_margin_bin competitors_bin;

***EXAMINE DESCRIPTIVE STATISTICS***;
proc freq data=construction_t nlevels;
	tables &categorical;
run;

proc means data=construction_t;
	var &continuous;
run;

***REGION, COMPB, COMPE, COMPF, COMPH, COMPJ ALL SIGNIFICANT AT 0.01 LEVEL***;
***REQUIRE EXACT TEST (20% OF EXPECTED CELL COUNTS <5): COMPC***;
proc freq data=construction_t;
	tables &categorical*BID_WON / chisq cellchi2 expected relrisk nocol nopercent measures cl;
	title "Chi-Square Test of Association with BID_WON";
run;
title;

***CHECK FOR SIGNIFICANCE OF CATEGORICAL VARIABLES***;
proc logistic data=construction_t alpha=.01;
	class &categorical / param=ref ref=last;
	model BID_WON (event='Yes') = &categorical / clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
run;

***BACKWARD & STEPWISE RESULTS DIFFER - HINTS AT POSSIBLE INTERACTION***;
proc logistic data=construction_t alpha=.01;
	class &categorical / param=ref ref=last;
	model BID_WON (event='Yes') = &categorical / clodds=pl SELECTION=STEPWISE slentry=.01 slstay=.01;
run;

***CHECK FOR INTERACTION BETWEEN SECTOR/REGION & COMPB/COMPC***;
proc logistic data=construction_t alpha=.01;
	class &categorical / param=ref ref=last;
	model BID_WON (event='YES') = &categorical2|SECTOR &categorical2|REGION @2 / clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
run;

***COLLAPSE SECTOR INTO PRIVATE VS. PUBLIC***;
data construction_t;
	set construction_t;
*CREATE SECTOR_TYPE WHERE 0=PRIVATE & 1=PUBLIC*;
	if sector=1 then sector_type=1;
	if 5<=sector<=7 then sector_type=1;
	if sector=10 then sector_type=1;

	if 2<=sector<=4 then sector_type=0;
	if 8<=sector<=9 then sector_type=0;

	label sector_type="Private vs. Public Sector";

*CREATE REGION_TYPE WHERE 0=WARM & 1=COLD*;
	if region='Southeast' then region_type=0;
	if region='Southwest' then region_type=0;
	if region='West' then region_type=0;

	if region='Northeast' then region_type=1;
	if region='Mid-west' then region_type=1;

	label region_type='Warm vs. Cold';
run;

***QUASI-COMPLETE SEPARATION STILL EXISTS FOR WIN_BID*MIDWEST REGION***;
proc freq data=construction_t nlevels;
	tables bid_won*sector*region;
run;

***RUN LABARRS BT MACRO ON ALL CONTINUOUS VARIABLES***;
%macro logitassump(target, vars, data, outfinal);
  %let k=1;
  %let dep = %scan(&vars, &k);
  %do %while("&dep" NE "");
  	data testing;
		set &data;
		x = &dep;
		xlogx = &dep*log(&dep);
		label x = "&dep" xlogx = "Box-Tidwell &dep";
	run;
	title "Model for only &dep";
    proc logistic data=testing;
      model &target = x  / parmlabel;
	  ods output ParameterEstimates = Work.BetaI&k;
    run;
    title "Model for both &dep and log(&dep)";
    proc logistic data=testing;
      model &target = &dep xlogx  / parmlabel;
	  ods output ParameterEstimates = Work.BetaL&k;
    run;
	data Beta_&dep;
      set BetaI&k BetaL&k; 
    run;
	data _null_;
		set Beta_&dep;
		if Variable ne 'x' then delete;
		call symput('beta', Estimate);
	run;
	data _null_;
		set Beta_&dep;
		if Variable ne 'xlogx' then delete;
		call symput('delta', Estimate);
	run;
	data BetaL&k;
		set BetaL&k;
		if Variable = 'xlogx' then Exponent = 1 + (&delta/&beta);
		else Exponent = .;
	run;
    %let k = %eval(&k + 1);
    %let dep = %scan(&vars, &k);
  %end;
  %if "&outfinal" NE "" %then 
  %do;
    data &outfinal;
      set 
      %do i = 1 %to &k - 1;
        BetaL&i
      %end; 
      ;
	  if Variable ne 'xlogx' then delete;
	  keep ProbChiSq Exponent Label;
    run;	  
    %let k = %eval(&k - 1);
    proc datasets;
      delete BetaI1 - BetaI&k;
    run;
	quit;
	proc datasets;
      delete BetaL1 - BetaL&k;
    run;
	quit;
  %end;
  %else 
  %do;
     %put no dataset name was provided, files are not combined;
  %end;
%mend;

%logitassump(bid_won, &continuous, work.construction_t, work.BoxTidwell)

***ALL CONTINUOUS VARIABLES MEET LINEARITY ASSUMPTIONS***;
proc sort data=BoxTidwell;
	by ProbChiSq;
run;

***CHECK FOR SIGNIFICANCE OF CONTINUOUS VARIABLES - MODEL DOES NOT CONVERGE***;
proc logistic data=construction_t alpha=.01;
	model BID_WON (event='Yes') = &continuous2 / clodds=pl SELECTION=FORWARD slentry=.01 slstay=.01;
run;

***NO OPTIMAL CLUSTERS EXIST***;
proc varclus data=construction_t maxeigen=1;
	var &continuous;
run;

***BIN CONTINUOUS VARIABLES***;
data construction_t;
	set construction_t;
	if cost_est<99 then cost_est_bin=1;
	if 100<=cost_est<300 then cost_est_bin=2;
	if cost_est>=300 then cost_est_bin=3;
	*if 240<=cost_est<320 then cost_est_bin=4;
	*if cost_est>=240 then cost_est_bin=4;
	label cost_est_bin='Binned Cost Estimate 1-3';

	if est_time<1 then est_time_bin=1;
	if 1<=est_time<=5 then est_time_bin=2;
	if est_time>5 then est_time_bin=3;
	label est_time_bin='Binned Time Estimate 1-3';

	if profit_margin<.08 then profit_margin_bin=1;
	if .08<=profit_margin<=.10 then profit_margin_bin=2;
	if profit_margin>.10 then profit_margin_bin=3;
	label profit_margin_bin='Binned Profit Margin 1-3';

	if competitors<=13 then competitors_bin=1;
	if competitors>13 then competitors_bin=2;
	*if competitors>16 then competitors_bin=3;
	label competitors_bin='Binned Competition 1-2';
run;

proc freq data=construction_t;
	tables bid_won*compe;
	tables bid_won*compf;
run;

proc univariate data=construction_t;
	var competitors;
	histogram competitors / normal kernel;
run;


proc logistic data=construction_t alpha=.01;
	class COMPB COMPE COMPF COMPH COMPJ SECTOR_type REGION cost_est_bin est_time_bin profit_margin_bin competitors_bin / param=ref ref=first;
	model BID_WON (event='Yes') = COMPB COMPE COMPF COMPH COMPJ SECTOR_type REGION cost_est_bin est_time_bin profit_margin_bin competitors_bin
									/ clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
run;


proc logistic data=construction_t alpha=.01;
	class COMPB COMPE COMPF COMPH COMPJ SECTOR REGION_type cost_est_bin est_time_bin profit_margin_bin competitors_bin / param=ref ref=first;
	model BID_WON (event='Yes') = COMPB COMPE COMPF COMPH COMPJ SECTOR REGION_type cost_est_bin est_time_bin profit_margin_bin competitors_bin
									/ clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
run;

proc logistic data=construction_t alpha=.01;
	class COMPB COMPE COMPF COMPH COMPJ SECTOR REGION cost_est_bin est_time_bin profit_margin_bin competitors_bin / param=ref ref=first;
	model BID_WON (event='Yes') = COMPB COMPE COMPF COMPH COMPJ SECTOR REGION cost_est_bin est_time_bin profit_margin_bin competitors_bin
									/ clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
run;

***TRY DIFFERENT BINNING METHOD FOR CATEGORICAL VARIABLES***;
data construction_t;
	set construction_t;

	if 4<=sector<=6 then sector_type=1;
	if 1<=sector<=3 then sector_type=0;
	if 7<=sector<=10 then sector_type=0;

	if region='West' then region_type=0;
	if region='Southeast' then region_type=0;
	if region='Northeast' then region_type=1;
	if region='Mid-west' then region_type=1;
	if region='Southwest' then region_type=1;

run; 

***CHECK FOR SIGNIFICANCE OF CATEGORICAL VARIABLES***;
proc logistic data=construction_t alpha=.01;
	class SECTOR_type REGION_type COMPA--COMPJ / param=ref ref=last;
	model BID_WON (event='Yes') = SECTOR_type REGION_type COMPA--COMPJ / clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
run;

proc logistic data=construction_t alpha=.01;
	class SECTOR_type REGION_type COMPA--COMPJ / param=ref ref=last;
	model BID_WON (event='Yes') = SECTOR_type REGION_type COMPA--COMPJ / clodds=pl SELECTION=STEPWISE slentry=.01 slstay=.01;
run;

proc logistic data=construction_t alpha=.01;
	class cost_est_bin est_time_bin profit_margin_bin competitors_bin / param=ref ref=first;
	model BID_WON (event='Yes') = compa--compj SECTOR_type REGION_type cost_est est_time_bin profit_margin 
									/ clodds=pl SELECTION=STEPWISE slentry=.01 slstay=.01;
	*exact &binned / estimate=both;
run;

proc logistic data=construction_t alpha=.01;
	class est_time_bin profit_margin_bin competitors_bin / param=ref ref=first;
	model BID_WON (event='Yes') = compe|compf|compj|SECTOR_type|REGION_type cost_est profit_margin @2
									/ clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
	*exact cost_est / estimate=both;
run;

proc logistic data=construction_t alpha=.01;
	class est_time_bin profit_margin_bin competitors_bin / param=ref ref=first;
	model BID_WON (event='Yes') = compe|compf|compj|SECTOR_type|REGION_type cost_est profit_margin @2
									/ clodds=pl SELECTION=BACKWARD slentry=.01 slstay=.01;
	*exact cost_est / estimate=both;
run;


***COMPARE ROC CURVES - BEST IS BEST***;
proc logistic data=construction_t alpha=.01;
	class region sector est_time_bin profit_margin_bin competitors_bin cost_est_bin/ param=ref ref=first;
	model bid_won (event='Yes')= compa--compj SECTOR_type REGION_type cost_est est_time_bin profit_margin_bin profit_margin competitors_bin cost_est cost_est_bin region sector / clodds=pl;
	ROC 'BEST' compe compf compj SECTOR_type REGION_type profit_margin competitors_bin cost_est;
	ROC 'Omit COMPJ' compe compf SECTOR_type REGION_type profit_margin competitors_bin cost_est;
	ROC 'REGION' compe compf SECTOR_type REGION profit_margin competitors_bin cost_est;
	ROC 'SECTOR' compe compf SECTOR REGION_type profit_margin competitors_bin cost_est;
	ROC 'COST_EST_BIN' compe compf SECTOR_type REGION_type profit_margin competitors_bin cost_est_bin;
	ROC 'PROFIT_MARGIN_BIN' compe compf compj SECTOR_type REGION_type profit_margin_bin competitors_bin cost_est;
	ROC 'OMIT COMP_BIN' compe compf compj SECTOR_type REGION_type profit_margin cost_est;
	ROCcontrast / estimate=allpairs;
	title 'Comparing ROC Curves';
run;

*ods graphics on;
proc logistic data=construction_t alpha=.01;
	class competitors_bin / param=ref ref=first;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin competitors_bin cost_est
								/ clodds=pl outroc=ROC;
run;

***EXAMINE CLASSIFICATION RATE TABLE FOR ALL CUTOFFS - BEST IS 0.57 WITH 92.9% SUCCESS RATE ***;
proc logistic data=construction_t alpha=.01;
	class competitors_bin / param=ref ref=first;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin competitors_bin cost_est
									/ clodds=pl ctable pprob=0 to .99 by .005;
run;

***SCORE DATA ON TRAINING SET - 6.66% ERROR RATE***;
proc logistic data=construction_t alpha=.01;
	class competitors_bin / param=ref ref=first;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin competitors_bin cost_est / pprob=.57;
	score data=construction_t out=training_score;
run;
	
data training_score;
	set training_score;
	if P_Yes > 0.57 then Predicted = 1;
	else Predicted = 0;
run;

proc freq data=training_score;
	tables bid_won*Predicted / nocol nopercent norow;
run;
quit;

***REMOVE COMP_BIN SINCE IT CAN'T BE USED IN FORECAST***;
proc logistic data=construction_t alpha=.01;
	class competitors_bin / param=ref ref=first;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin cost_est
								/ clodds=pl outroc=ROC;
run;

***EXAMINE CLASSIFICATION RATE TABLE FOR ALL CUTOFFS - BEST IS 0.555 WITH 92.4% SUCCESS RATE ***;
proc logistic data=construction_t alpha=.01;
	class competitors_bin / param=ref ref=first;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin cost_est
									/ clodds=pl ctable pprob=0 to .99 by .005;
run;

***SCORE DATA ON TRAINING SET - 6.9% ERROR RATE***;
proc logistic data=construction_t alpha=.01;
	class competitors_bin / param=ref ref=first;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin cost_est / pprob=.555;
	score data=construction_t out=training_score;
run;
	
data training_score;
	set training_score;
	if P_Yes > 0.555 then Predicted = 1;
	else Predicted = 0;
run;

proc freq data=training_score;
	tables bid_won*Predicted / nocol nopercent norow;
run;
quit;

*==============================================***TRANSFORM VALIDATION DATA***======================================*;
data construction_v;
	set project.construction_v;

	PROFIT_MARGIN=100*EST_PROFIT/BID_PRICE;

	if 4<=sector<=6 then sector_type=1;
	if 1<=sector<=3 then sector_type=0;
	if 7<=sector<=10 then sector_type=0;

	if region='West' then region_type=0;
	if region='Southeast' then region_type=0;
	if region='Northeast' then region_type=1;
	if region='Mid-west' then region_type=1;
	if region='Southwest' then region_type=1;

run;

***SCORE DATA ON VALIDATION SET - 16.67% ERROR RATE***;
proc logistic data=construction_t alpha=.01;
	class competitors_bin / param=ref ref=first;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin cost_est / pprob=.555;
	score data=construction_v out=training_score_v;
run;
	
data training_score_v;
	set training_score_v;
	if P_Yes > 0.555 then Predicted = 1;
	else Predicted = 0;
run;

proc freq data=training_score_v;
	tables bid_won*Predicted / nocol nopercent norow;
run;
quit;

***SWITCH REFERENCE LEVELS***;
data construction_m;
	set project.construction_t;

	PROFIT_MARGIN=100*EST_PROFIT/BID_PRICE;

	if 4<=sector<=6 then sector_type=0;
	if 1<=sector<=3 then sector_type=1;
	if 7<=sector<=10 then sector_type=1;

	if region='West' then region_type=1;
	if region='Southeast' then region_type=1;
	if region='Northeast' then region_type=0;
	if region='Mid-west' then region_type=0;
	if region='Southwest' then region_type=0;

run;

proc logistic data=construction_m alpha=.01;
	model BID_WON (event='Yes') = compe compf compj SECTOR_type REGION_type cost_est profit_margin / clodds=pl;
run;
