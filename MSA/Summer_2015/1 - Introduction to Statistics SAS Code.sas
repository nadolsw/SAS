/* Introduction to Statistics */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Intro to Statistics SAS Report.rtf";
*ods rtf;
*options nodate nonumber ls=95 ps=80;

/*******************/
/* Variable MACROS */
/*******************/

/* Defining Categorical Variables */
%let categorical=House_Style Overall_Qual Overall_Cond Year_Built 
         Fireplaces Mo_Sold Yr_Sold Garage_Type_2 Foundation_2 
         Heating_QC Masonry_Veneer Lot_Shape_2 Central_Air;

/* Defining Interval Variables */
%let interval=SalePrice Log_Price Gr_Liv_Area Basement_Area 
         Garage_Area Deck_Porch_Area Lot_Area Age_Sold Bedroom_AbvGr 
         Full_Bathroom Half_Bathroom Total_Bathroom ;


/******************/
/* Exploring Data */
/******************/

/* Listing Out Observations in Data Set */
proc print data=bootcamp.ameshousing3 (obs=10);
    title 'Listing of the Ames Housing Data Set';
run;

/* Frequencies of Categorical Variables */
proc freq data=bootcamp.ameshousing3;
    tables &categorical / plots=freqplot ;
    format House_Style $House_Style.
           Overall_Qual Overall.
           Overall_Cond Overall.
           Heating_QC $Heating_QC.
           Central_Air $NoYes.
           Masonry_Veneer $NoYes.
           ;
    title "Categorical Variable Frequency Analysis";
run;

/* Basic Summary Statistics */
proc means data=bootcamp.ameshousing3;
    var &interval;
    title 'Descriptive Statistics of Ames Data';
run;

/* Splitting the Summary Statistics by House Style */
proc means data=bootcamp.ameshousing3 printalltypes;
	class House_Style;
	var SalePrice;
	title 'Descriptive Statistics by House Style';
run;

/* Calculating Other Summary Statistics */
proc means data=bootcamp.ameshousing3 
           maxdec=2 
           n mean median std q1 q3 qrange;
    var SalePrice;
    title 'Selected Descriptive Statistics';
run;

/* Distribution Exploration of Interval Variables */
ods select histogram;
proc univariate data=bootcamp.ameshousing3 noprint;
    var &interval;
    histogram &interval / normal kernel;
    inset n mean std / position=ne;
    title "Interval Variable Distribution Analysis";
run;

/* Summary Statistics, Histograms, & QQ-Plots */
proc univariate data=bootcamp.ameshousing3;
    var SalePrice;
    histogram SalePrice / normal(mu=est sigma=est) kernel;
    inset skewness kurtosis / position=ne;
    probplot SalePrice / normal(mu=est sigma=est);
    inset skewness kurtosis;
    title 'Descriptive Statistics of Sales Price';
run;

/* Vertical Box-plot with SGPLOT */
proc sgplot data=bootcamp.ameshousing3;
    vbox SalePrice / ; *datalabel=Overall_Qual;
    refline 135000 / axis=y label;
    title "Box Plots of Sales Prices";
run;


/************************/
/* Confidence Intervals */
/************************/

/* Confidence Interval for the Mean */
proc means data=bootcamp.ameshousing3 maxdec=2
           n mean std stderr clm;
    var SalePrice;
    title '95% Confidence Interval for Sales Price';
run;


/**********************/
/* Hypothesis Testing */
/**********************/

/* Hypothesis Test */
ods graphics off;
ods select testsforlocation;
proc univariate data=bootcamp.ameshousing3 mu0=135000;
    var SalePrice;
    title 'Testing Whether the Mean of Sales Price = $135K';
run;
ods graphics on;

/* Hypothesis Test (Another Way) */
proc ttest data=bootcamp.ameshousing3 
           plots(shownull)=interval
           H0=135000;
    var SalePrice;
    title "One-Sample t-Test Testing Mean"
		  " SalePrice=$135K";
run;

/* Two-Sample t-Test */
proc ttest data=bootcamp.ameshousing3 plots(shownull)=interval;
    class Masonry_Veneer;
    var SalePrice;
    format Masonry_Veneer $NoYes.;
    title "Two-Sample t-test Comparing Masonry Veneer, No vs. Yes";
run;


*ods rtf close;
*ods html;
