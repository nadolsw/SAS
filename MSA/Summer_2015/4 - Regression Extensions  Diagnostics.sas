/* Regression Extensions & Diagnostics */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Regression Extensions & Diagnostics SAS Report.rtf";
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


/*************/
/* Residuals */
/*************/

/* Residual Plots */
proc reg data=bootcamp.ameshousing3 
	plots (only)=diagnostics (unpack);
   	model SalePrice = &interval;
	output out=out r=residuals;
	title 'Sale Price Regression and Diagnostics';
run;
quit; 


/********************************/
/* Polynomial Regression Models */
/********************************/

/* Simple Polynomial Regression - Plot */
proc sgplot data=bootcamp.ameshousing3;
	scatter x = Basement_Area y = SalePrice;
	title1 "Polynomial Relationships";
	title2 "Scatter Plot";
run;

proc sgplot data=bootcamp.ameshousing3;
	reg  x = Basement_Area y = SalePrice 
		 / lineattrs =(color=brown pattern=solid) 
		   legendlabel="Linear";
	title2 "Linear Model";
run; 

proc sgplot data=bootcamp.ameshousing3;
	reg  x = Basement_Area y = SalePrice 
		 / degree=2 lineattrs =(color=green pattern=mediumdash) 
		   legendlabel="2nd Degree";
	title2 "Second Degree Polynomial";
run;

proc sgplot data=bootcamp.ameshousing3;
	reg  x = Basement_Area y = SalePrice 
		 / degree=3 lineattrs =(color=red pattern=shortdash) 
		   legendlabel="3rd Degree";
	title2 "Third Degree Polynomial";
run;

proc sgplot data=bootcamp.ameshousing3;
	reg  x = Basement_Area y = SalePrice 
		 / degree=4 lineattrs =(color=blue pattern=longdash) 
		   legendlabel="4th Degree";
	title2 "Fourth Degree Polynomial";
run;

/* Creating Polynomial Terms */
data ameshousing3;
	set bootcamp.ameshousing3;
	BA2 = Basement_Area**2;
	BA3 = Basement_Area**3;
	BA4 = Basement_Area**4;
run;

/* Simple Polynomial Regression Model */
proc reg data=ameshousing3 ;
	model SalePrice = Basement_Area;
run;
quit; 

proc reg data=ameshousing3 ;
	model SalePrice = Basement_Area BA2 BA3 BA4 / scorr1(tests);
	title "Sale Price Data Set: 4th Degree Polynomial";
run;
quit;


/*********************/
/* Multicollinearity */
/*********************/

/* Multicollinearity Diagnostics */
proc corr data=ameshousing3 nosimple plots=matrix;
   var Basement_Area BA2 BA3;
   title 'Collinearity Diagnosis for the Cubic Model';
run;

proc reg data=ameshousing3;
   model SalePrice = Basement_Area BA2 BA3 / vif collin collinoint;
run;
quit;

/* Centering Variables */
proc stdize data=bootcamp.ameshousing3 method=mean 
		    out=ameshousing3_center(rename=(Basement_Area = Center_BA));
   var Basement_Area;
run;

data ameshousing3_center;
   set ameshousing3_center;
   Center_BA2 = Center_BA**2;
   Center_BA3 = Center_BA**3;
run;   

/* Using SQL and a DATA step to center the variable */
proc sql;
   select mean(Basement_Area) into: Mean_BA
   from bootcamp.ameshousing3;
run;

data ameshousing3_center;
   set bootcamp.ameshousing3;
   Center_BA = Basement_Area - &Mean_BA;
   Center_BA2 = Center_BA**2;
   Center_BA3 = Center_BA**3;
run;

/* Centered Variables in Regression */
proc reg data=ameshousing3_center;
   model SalePrice = Center_BA Center_BA2 Center_BA3 / 
                    vif collin collinoint;
   title 'Centered Cubic Model';
run;
quit;


/**********************/
/* Heteroscedasticity */
/**********************/

/* Detecting Heteroscedasticity - Plot */
proc reg data=bootcamp.ameshousing3 plots(unpack);
   	model SalePrice = &interval;
	title 'Sale Price Regression and Diagnostics';
run;
quit; 

/* Detecting Heteroscedasticity - Formal Tests */
proc model data=bootcamp.ameshousing3;
	parms B0 B1 B2 B3 B4 B5 B6 B7;
	SalePrice = B0 + B1*Gr_Liv_Area + B2*Basement_Area + B3*Garage_Area 
			 + B4*Deck_Porch_Area + B5*Lot_Area + B6*Age_Sold 
			 + B7*Bedroom_AbvGr;
	fit SalePrice / white breusch=(1 Gr_Liv_Area);
	fit SalePrice / white breusch=(1 Basement_Area);
	fit SalePrice / white breusch=(1 Gr_Liv_Area Basement_Area);
run;
quit;

/* Detecting Heteroscedasticity - Spearman Correlation */
proc reg data=bootcamp.ameshousing3 plots(unpack) noprint;
   	model SalePrice = &interval;
	output out=check r=residual p=pred;
	title 'Sale Price Regression and Diagnostics';
run;
quit; 								

data check;
   set check;
   abserror=abs(residual);
run;

proc corr data=check spearman nosimple;
   var abserror pred;
run;

/* Heterscedasticity Robust Standard Errors */
proc model data=bootcamp.ameshousing3;
	parms B0 B1 B2 B3 B4 B5 B6 B7;
	SalePrice = B0 + B1*Gr_Liv_Area + B2*Basement_Area + B3*Garage_Area 
			 + B4*Deck_Porch_Area + B5*Lot_Area + B6*Age_Sold 
			 + B7*Bedroom_AbvGr;
	fit SalePrice / HCCME=NO outest=ols covout;
	fit SalePrice / HCCME=0 outest=H0 covout;
	fit SalePrice / HCCME=1 outest=H1 covout;
	fit SalePrice / HCCME=2 outest=H2 covout;
	fit SalePrice / HCCME=3 outest=H3 covout;
run;
quit;

/* Weighted Least Squares - Adjusted Variance Part 1 */
data WLS_ameshousing3;
	set bootcamp.ameshousing3;
	wt1 = 1/Gr_Liv_Area;
run;

proc reg data=WLS_ameshousing3 plots(unpack);
   	model SalePrice = &interval;
	weight wt1;
	title 'WLS on Sale Price';
run;
quit; 

/* Weighted Least Squares - Adjusted Variance Part 2 */
proc reg data=bootcamp.ameshousing3 noprint;
   	model SalePrice = &interval;
	output out=Resid r=residual;
	title 'Sale Price Regression and Diagnostics';
run;
quit; 	

data test;
	set Resid;
	log_e = log(residual*residual);
	log_Gr_Liv_Area = log(Gr_Liv_Area);
run;

proc reg data=test;
	model log_e = log_Gr_Liv_Area;
	output out=Resid2 p=Pred;
run;
quit;

data test;
	set Resid2;
	wt2 = 1/exp(Pred);
run;

proc reg data=test plots(unpack);
   	model SalePrice = &interval;
	weight wt2;
	title 'WLS Using FGLS - Method 1';
run;
quit; 

/* Weighted Least Squares - Adjusted Variance Part 3 */
proc reg data=bootcamp.ameshousing3 noprint;
   	model SalePrice = &interval;
	output out=Resid r=residual;
	title 'Sale Price Regression and Diagnostics';
run;
quit; 	

data test2;
	set Resid;
	log_e = log(residual*residual);
run;

proc reg noprint data=test2;
	model log_e = Gr_Liv_Area;
	output out=Resid3 p=Pred;
run;

data test2;
	set Resid3;
	wt3 = 1/exp(Pred);
run;

proc reg data=test plots(unpack);
   	model SalePrice = &interval;
	weight wt3;
	title 'WLS Using FGLS - Method 2';
run;
quit; 


/*********************/
/* Lack of Normality */
/*********************/

/* Histogram and QQ-plot for Residuals */
proc reg data=bootcamp.ameshousing3 plots(unpack);
   	model SalePrice = &interval;
	output out=check r=residual;
	title 'Sale Price Regression and Diagnostics';
run;
quit; 

/* Formal Tests for Normality */
proc univariate data=check normal plots;
  var residual;
run;


/*****************************************/
/* Outliers and Influential Observations */
/*****************************************/

/* Summary of Outlier & Influential Statistics */
proc reg data=bootcamp.ameshousing3 plots(unpack label)=all;
   model SalePrice = &interval / influence spec partial;
   id PID;
   output out=check r=residual p=pred rstudent=rstudent h=leverage;
run;
quit; 


/**************************/
/* Correlated Error Terms */
/**************************/

/* Durbin-Watson Test */
proc reg data=bootcamp.Minntemp;
	model Temp = Time TimeSq / dwProb;
run;
quit;

/* Higher Orders of Durbin-Watson Test */
proc autoreg data=bootcamp.Minntemp plot(unpack)=all;
	model Temp = Time TimeSq / dw=24 dwprob;
run;



*ods rtf close;
*ods html;
