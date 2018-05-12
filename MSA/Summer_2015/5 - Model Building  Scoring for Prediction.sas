/* Model Building & Scoring for Prediction */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Model Building & Scoring for Prediction SAS Report.rtf";
*ods rtf;
*options nodate nonumber ls=95 ps=80;

/*******************/
/* Variable MACROS */
/*******************/

/* Defining Categorical Variables */
%let categorical=House_Style2 Overall_Qual2 Overall_Cond2 Fireplaces 
         Season_Sold Garage_Type_2 Foundation_2 Heating_QC 
         Masonry_Veneer Lot_Shape_2 Central_Air;

/* Defining Interval Variables */
%let interval=Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
         Lot_Area Age_Sold Bedroom_AbvGr;


/*********************/
/* Data Partitioning */
/*********************/

/* Creating Validation Data Sets - Data Step*/
data ameshousing3_train ameshousing3_valid;
	set bootcamp.ameshousing3;
	random = RAND("Uniform");
	if random <=0.2 then output ameshousing3_valid;
	else output ameshousing3_train;
run;

/* Creating Validation Data Sets - PROC SURVEYSELECT*/
proc surveyselect data=bootcamp.ameshousing3 method=srs rate=0.2
				  out=ameshousing3_split outall;
run;

data ameshousing3_train ameshousing3_valid;
	set ameshousing3_split;
	if Selected = 1 then output ameshousing3_valid;
	else output ameshousing3_train;
run;


/************************/
/* Prediction / Scoring */
/************************/

/* Predicted Values with PROC SCORE */
proc reg data=ameshousing3_train outest=Betas
	plots (only)=diagnostics (unpack);
   	*Full: model SalePrice = &interval;
	Reduced: model SalePrice = Gr_Liv_Area Basement_Area Garage_Area 
							   Deck_Porch_Area Age_Sold;
	title 'Sale Price Regression';
run;
quit; 

proc score data=ameshousing3_valid score=Betas out=Scored type=parms;
	var Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area Age_Sold;
run;

data MAPE;
	set Scored;
	AE = abs(Reduced - SalePrice);
	APE = (abs(Reduced - SalePrice) / SalePrice)*100;
run;

proc means data=MAPE mean;
	var AE APE;
run;

/* Predicted Values with Data Step */
data ameshousing3_split2;
	set ameshousing3_split;
	if Selected = 1 then SalePrice = .;
run;

proc reg data=ameshousing3_split2
	plots (only)=diagnostics (unpack);
   	*Full: model SalePrice = &interval;
	Reduced: model SalePrice = Gr_Liv_Area Basement_Area Garage_Area 
							   Deck_Porch_Area Age_Sold;
	output out=Scored p=pred;
	title 'Sale Price Regression';
run;
quit; 

data Scored;
	set Scored;
	if SalePrice ne . then delete;
run;

data Scored;
	merge Scored ameshousing3_valid;
	keep SalePrice Pred;
run;

data MAPE;
	set Scored;
	AE = abs(Pred - SalePrice);
	APE = (abs(Pred - SalePrice) / SalePrice)*100;
run;

proc means data=MAPE mean;
	var AE APE;
run;


*ods rtf close;
*ods html;
