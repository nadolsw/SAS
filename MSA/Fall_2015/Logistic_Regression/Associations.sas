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

%let categorical = sector region compA compB compC compD compE compF compG compH compI compJ ;
%let binary = compA compB compC compD compE compF compG compH compI compJ ;
/*%let ordinal = ;*/ *The only ordinal variables are the binary ones;
%let nominal = sector region ;
%let continuous = est_profit cost_est est_time bid_price winning_price cost_eng competitors;


*Chisq Assocations;
title1 'Exploring Associations with Winning Bids';
proc freq data=construction;
    tables (&categorical.)*bid_won / chisq expected cellchi2 nocol nopercent ; 
run;
