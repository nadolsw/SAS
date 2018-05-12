/* Introduction to ANOVA & Regression */
/*----------------------------------------------------------------------------------*/
*ods html close;
*ods rtf file="Introduction to ANOVA & Regression SAS Report.rtf";
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



/*****************************/
/* Exploratory Data Analysis */
/*****************************/

/* Scatter Plots of Continuous Variables */
proc sgscatter data=bootcamp.ameshousing3;
    plot SalePrice*Gr_Liv_Area / reg;
    title "Associations of Above Grade Living"
		  " Area with Sale Price";
run;

options nolabel;
proc sgscatter data=bootcamp.ameshousing3;
    plot SalePrice*(&interval) / reg;
    title "Associations of Interval Variables with Sale Price";
run;

/* Box Plots of Categorical Variables */
proc sgplot data=bootcamp.ameshousing3;
    vbox SalePrice / category=Central_Air 
                     connect=mean;
    title "Sale Price Differences across Central Air";
run;

/* MACRO for Box Plots on all Categorical Variables */
%macro box(dsn      = ,
           response = ,
           Charvar  = );
%let i = 1 ;
%do %while(%scan(&charvar,&i,%str( )) ^= %str()) ;

    %let var = %scan(&charvar,&i,%str( ));

    proc sgplot data=&dsn;
        vbox &response / category=&var 
                         grouporder=ascending 
                         connect=mean;
        title "&response across Levels of &var";
    run;

    %let i = %eval(&i + 1 ) ;
%end ;
%mend box;

%box(dsn      = bootcamp.ameshousing3,
     response = SalePrice,
     charvar  = &categorical);


/*****************/
/* One-Way ANOVA */
/*****************/

/* Descriptive Statistics Across Groups */
proc means data=bootcamp.ameshousing3 printalltypes maxdec=3;
    var SalePrice;
    class Heating_QC;
    title 'Descriptive Statistics of Sales Price';
run;

proc sgplot data=bootcamp.ameshousing3;
    vbox SalePrice / category=Heating_QC 
                     connect=mean;
    title "Sale Price Differences across Heating Quality";
run;

/* One-Way ANOVA */
proc glm data=bootcamp.ameshousing3;
    class Heating_QC;
    model SalePrice=Heating_QC;
    format Heating_QC $Heating_QC.;
    title "One-Way ANOVA with Heating Quality"
		  " as Predictor";
run;
quit;

/* Testing the Assumptions of a One-Way ANOVA */
proc glm data=bootcamp.ameshousing3;
    class Heating_QC;
    model SalePrice=Heating_QC;
	means Heating_QC / hovtest=levene;
    format Heating_QC $Heating_QC.;
    title "One-Way ANOVA Equal Variance Test";
run;
quit;


/************************/
/* ANOVA Post-Hoc Tests */
/************************/

/* Post-Hoc Pairwise Comparisons */
ods select lsmeans diff diffplot controlplot;
proc glm data=bootcamp.ameshousing3 
         plots(only)=(diffplot(center) controlplot);
    class Heating_QC;
    model SalePrice=Heating_QC;
    lsmeans Heating_QC / pdiff=all 
                         adjust=tukey;
    lsmeans Heating_QC / pdiff=control('Average/Typical') 
                         adjust=dunnett;
    format Heating_QC $Heating_QC.;
    title "Post-Hoc Analysis of ANOVA - Heating Quality as Predictor";
run;
quit;


/***********************/
/* Pearson Correlation */
/***********************/

/* Descriptive Statistics Across Groups */
ods graphics / reset=all imagemap;
proc corr data=bootcamp.ameshousing3 rank
          plots(only)=scatter(nvar=all ellipse=none);
   var &interval;
   with SalePrice;
   id PID;
   title "Correlations and Scatter Plots with SalePrice";
run;

/* Correlation Matrix */
proc corr data=bootcamp.ameshousing3 
          nosimple
		  plots=matrix(nvar=all histogram);
   var SalePrice &interval;
   title "Correlations and Scatter Plot Matrix of Predictors";
run;

proc corr data=bootcamp.ameshousing3 
          nosimple
		  plots=matrix(nvar=all histogram);
   var SalePrice Gr_Liv_Area Basement_Area;
   title "Scatter Plot Matrix of Predictors";
run;


/****************************/
/* Simple Linear Regression */
/****************************/

/* Simple Linear Regression */
proc reg data=bootcamp.ameshousing3;
    model SalePrice=Lot_Area;
    title "Simple Regression with Lot Area as Predictor";
run;
quit;


*ods rtf close;
*ods html;
