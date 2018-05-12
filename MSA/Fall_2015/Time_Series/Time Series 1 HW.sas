/* This program is for the first homework of Time series dealing with US Retail Sales */

libname LWFETSP "C:\Users\Owner\Desktop\MSA\Time Series 1\Data";
 ods listing gpath = "%sysfunc(pathname(work))";

proc print data = LWFETSP.Us_Retail_Sales;
run;

/* First I plotted the data to look at possible time trends
	Q: Difference between t and Date?
*/
proc sgplot data = LWFETSP.Us_Retail_Sales;
	title 'US Retail Sales in Millions';
	scatter y=sales x=t;
	*series Y=Sales X=Date;
	* series Y=Sales X=Year;
	*series Y=Sales X=Month;
run;

/* Next I plotted the serious including 11 of the 12 months
	to consider seasonality 
	Q: In the code he gave at the end of the assignment it had all 12
*/
proc reg data = LWFETSP.US_Retail_Sales;
	Title 'Trend plus Seasonal Effect';
	model Sales = t mon1-mon11;
	output out=out1 predicted=p residual=r;
run;

/* I created an overlay plot of the actual (Scatter) and predicted (series) */
proc sgplot data = out1;
	title 'Predictions overlay Graph';
	Scatter x=date y=sales;
	series Y=p X=Date;
run;

/* I created a plot of the residuals from the initial model */
proc sgplot data = out1;
	title 'Residuals';
	series x=date y=r;
run;

/* This is a picture of the ramp variable vs date, specifically asked for */
proc sgplot data =  LWFETSP.Us_Retail_Sales;
	title 'Ramp Variable vs Date';
	series Y=Ramp X=date;
run;

/* Ran a regression with all the previous variables plus the Ramp option */
proc reg data = LWFETSP.US_Retail_Sales ;
	Title 'Trend plus Seasonal Effect and Ramp Variable';
	model Sales = t mon1-mon11 Ramp;
	output out=out2 predicted=p residual=r
				LCL=L95I UCL=U95I;
run;

/* This is an overaly plot with the predictions, the actual outcomes as well as the confidence intervals */
proc sgplot data = out2;
	title 'Predictions (Including Ramp) overlay Graph';
		Scatter x=date y=sales;
		series Y=p X=Date / lineattrs = (color=black thickness = 1);
		series Y = L95I X=date / lineattrs = (color=red thickness = 1 pattern=dash);
		series Y = U95I X = date /  lineattrs = (color=red thickness = 1 pattern=dash);
run;

/* Plots model 2's residuals */
proc sgplot data = out2;
	title 'Residuals of Model with Seasonal and Ramp';
	series x=date y=r;
run;
