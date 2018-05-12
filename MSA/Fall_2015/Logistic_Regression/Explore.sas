************************************************
* Binary Response Project
* Purpose - Explore data "plot your data..."
* Author - Michael H
* Date - 9/7/15
*************************************************;

libname project "C:\Users\Michael\Documents\Fall Classes\Binary Response Analytics\Project\Data";

data construction;
	set project.construction_t;
run;

*Frequencies of Categorical variables;
%let categorical = sector region compA compB compC compD compE compF compG compH compI compJ ;
%let binary = compA compB compC compD compE compF compG compH compI compJ ;
/*%let ordinal = ;*/ *The only ordinal variables are the binary ones;
%let nominal = sector region ;

*General exploration of frequencies;
title1 'Exploration of Frequencies';
proc freq data=construction;
	tables &categorical. bid_won;
run;


* Plots of Continuous Variables;
%let continuous = est_profit cost_est est_time bid_price winning_price cost_eng competitors;

title 'Continuous Variable Descriptive Statistics';
proc means data=construction maxdec=2 n mean median std q1 q3 qrange;
    var &continuous.;
run;

proc sort data=construction ; 
	by bid_won;
run;
 
proc means data=construction maxdec=2 n mean median std q1 q3 qrange;
    var &continuous.;
	by bid_won;
run;

*Histograms;
proc univariate data=construction noprint;
    var &continuous.;
    histogram &continuous. / normal kernel;
    inset n mean std / position=ne;
run;

*Histograms by won/loss;
proc univariate data=construction noprint;
    var &continuous.;
    histogram &continuous. / normal kernel;
	by bid_won;
    inset n mean std / position=ne;
run;
