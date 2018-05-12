************************************************
* Binary Response Project
* Purpose - Split and export analysis datasets
* Author - Michael H
* Date - 9/7/15
*************************************************;

libname project "C:\Users\Michael\Documents\Fall Classes\Binary Response Analytics\Project\Data";

*Import data into sas;
PROC IMPORT OUT= WORK.construction_full0 
            DATAFILE= "C:\Users\Michael\Documents\Fall Classes\Binary Response Analytics\Project\Data\Construction Data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


*Create better variable names;
data construction_full1;
	set construction_full0;
	rename 
	 Bid_Price__Millions_=			 bid_price
	 Competitor_A=					 compA
	 Competitor_B=					 compB
	 Competitor_C=					 compC
	 Competitor_D=					 compD
	 Competitor_E=					 compE
	 Competitor_F=					 compF
	 Competitor_G=					 compG
	 Competitor_H=					 compH
	 Competitor_I=					 compI
	 Competitor_J=					 compJ
	 Cost_After_Engineering_Estimate=cost_eng
	 Estimated_Cost__Millions_=		 cost_est
	 Estimated_Years_to_Complete= 	 est_time
	 Number_of_Competitor_Bids=		 competitors
	 Region_of_Country=				 region
	 /*Sector						                */
	 Win_Bid=						 bid_won
	 Winning_Bid_Price__Millions_=	 winning_price;
run;

*Create labels;
data construction_full;
	set construction_full1;
	label 
	 cost_est="Estimated Cost (Millions)"
	 est_time="Estimated Years to Complete"
	 bid_price="Bid Price (Millions)"
	 Sector="Sector"
	 region="Region"
	 competitors="Number of Competitors"
	 compA="Competitor A"
	 compB="Competitor B"
	 compC="Competitor C"
	 compD="Competitor D"
	 compE="Competitor E"
	 compF="Competitor F"
	 compG="Competitor G"
	 compH="Competitor H"
	 compI="Competitor I"
	 compJ="Competitor J"
	 bid_won="Successful Bid"
	 winning_price="Winning Bid Price (Millions)"
	 cost_eng="Cost After Engineering Estimate (Thousands)";
run;


*split data 80/20;
proc surveyselect data=construction_full method=srs rate=0.8
	out=construction_selection outall seed=9915;
run;

data project.construction_t project.construction_v ;
	set construction_selection ;
	label est_profit = "Estimated Profit (Millions)";
	est_profit=bid_price-cost_est-(cost_eng/1000);
	if selected=1 then output project.construction_t;
	else if selected=0 then output project.construction_v;
run;
	
*Output full dataset just in case;
data project.construction_full;
	set construction_full;
	label est_profit = "Estimated Profit (Millions)";
	est_profit=bid_price-cost_est-(cost_eng/1000);
run;



