/* More Complex ANOVA & Regression */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="More Complex ANOVA & Regression SAS Report.rtf";
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
         Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;


/***********************************/
/* Two-Way ANOVA with Interactions */
/***********************************/

/* Exploring Data for Two-Way ANOVA */
proc means data=bootcamp.ameshousing3
           mean var std nway;
    class Season_Sold Heating_QC;
    var SalePrice;
    format Season_Sold Season.;
    title 'Selected Descriptive Statistics';
run;

proc sgplot data=bootcamp.ameshousing3;
    vline Season_Sold / group=Heating_QC 
                        stat=mean 
                        response=SalePrice 
                        markers;
run; 

/* Two-Way ANOVA */
proc glm data=bootcamp.ameshousing3 order=internal;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold;
    lsmeans Season_Sold / diff adjust=tukey;
    title "Model with Heating Quality and Season as Predictors";
run;
quit;

/* Two-Way ANOVA with Interactions */
proc glm data=bootcamp.ameshousing3 
         order=internal 
         plots(only)=intplot;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold Heating_QC*Season_Sold;
    format Season_Sold Season.;
    title "Model with Heating Quality and Season as Interacting Predictors";
run;
quit;

/* Sliced ANOVA Results */
proc glm data=bootcamp.ameshousing3 
         order=internal 
         plots(only)=intplot;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold Heating_QC*Season_Sold;
    lsmeans Heating_QC*Season_Sold / diff slice=Heating_QC;
    title "Analyze the Effects of Season";
	title2 "at Each Level of Heating Quality";
	format Season_Sold Season.;
run;
quit;


/*************************************/
/* Randomized Block Design for ANOVA */
/*************************************/

/* ANOVA with Blocking */
proc glm data=bootcamp.MGGarlic_Block plots(only)=diagnostics;
     class Fertilizer Sector;
     model BulbWt=Fertilizer Sector;
     title 'ANOVA for Randomized Block Design';
run;
quit;


/******************************************/
/* Concepts of Multiple Linear Regression */
/******************************************/

/* Fitting a Multiple Linear Regression Model */
proc reg data=bootcamp.ameshousing3 ;
    model SalePrice=Basement_Area Lot_Area;
    title "Model with Basement Area and Lot Area";
run;
quit;


/*************************************/
/* Model Building and Interpretation */
/*************************************/

/* Stepwise Regression */
proc reg data=bootcamp.ameshousing3 plots(only)=adjrsq;
   FORWARD:  model SalePrice = &interval 
				   			   / selection=forward slentry=0.05;
   BACKWARD: model SalePrice = &interval 
							   / selection=backward slstay=0.05;
   STEPWISE: model SalePrice = &interval 
							   / selection=stepwise 
								 slentry=0.05 slstay=0.05;
   title 'Best Models Using Stepwise Selection';
run;
quit;

/* All-Regression Model Selection - R-squared */
proc reg data=bootcamp.ameshousing3 plots(only)=(rsquare adjrsq cp);
    ALL_REG: model SalePrice = &interval 
			 	   / selection=rsquare adjrsq cp;
    title 'Best Models Using All-Regression Option';
run;
quit;

/* All-Regression Model Selection - Mallow's Cp */
proc reg data=bootcamp.ameshousing3 plots(only)=(cp);
    ALL_REG: model SalePrice = &interval 
				   / selection=cp rsquare adjrsq best=20;
    title 'Best Models Using All-Regression Option';
run;
quit;


*ods rtf close;
*ods html;
