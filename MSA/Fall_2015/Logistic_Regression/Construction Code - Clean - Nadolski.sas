libname project "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Logisitc Regression\Homework\Data";

***CALCULATE PROFIT MARGIN AND BIN SECTOR & REGION***;
data construction_t;
	set project.construction_t;

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

***CHECK FOR SIGNIFICANT VARIABLES***;
proc logistic data=construction_t alpha=.01;
	class compa--compj sector_type region_type / param=ref ref=first;
	model BID_WON (event='Yes') = compa--compj SECTOR_type REGION_type cost_est profit_margin
									/ clodds=pl SELECTION=STEPWISE slentry=.01 slstay=.01;
run;

***EXAMINE CLASSIFICATION RATE TABLE FOR ALL CUTOFFS - BEST IS 0.555 WITH 92.4% SUCCESS RATE ***;
proc logistic data=construction_t alpha=.01;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin cost_est
									/ clodds=pl ctable pprob=0 to .99 by .005;
run;

***CALCULATE YOUDENS J - CORRESPONDS TO PROB CUTOFF OF 0.128771***;
proc logistic data=construction_t alpha=.01;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin cost_est
									/ clodds=pl outroc=ROC;
run;

data Youden;
	set ROC;
	_spec_=1-_1mspec_;
	J=_sensit_+_spec_-1;
run;

proc sql;
	select _prob_, J
	from Youden
	order J desc;
quit;

***CALCULATE COST FUNCTION - MISCLASSIFICATION COST MINIMIZED AT PROB CUTOFF = .024719***;
data Roc;
	set Roc;
	falpos_cost=241970*_falpos_;
	falneg_cost=11562700*_falneg_;
	false_cost=falpos_cost+falneg_cost;
run;

proc sgscatter data=roc;
	plot false_cost*_prob_;
run;

proc sql;
	select _prob_, false_cost
	from Roc
	order false_cost;
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


***SCORE DATA ON VALIDATION SET - 26.85% ERROR RATE***;
proc logistic data=construction_t alpha=.01;
	model bid_won (event='Yes')= compe compf compj SECTOR_type REGION_type profit_margin cost_est / pprob=0.024719;
	score data=construction_v out=training_score_v;
run;
	
data training_score_v;
	set training_score_v;
	if P_Yes > 0.024719 then Predicted = 1; else Predicted = 0;
run;

proc freq data=training_score_v;
	tables bid_won*Predicted / nocol nopercent norow;
run;
quit;
