

** CPI from Table 24 of Bureau of Labor Statistics (baseline 100 is 1982-84) 
   report found at   http://www.bls.gov/cpi/cpid1507.pdf  **; 

libname LWFETSP "C:\Users\Owner\Desktop\MSA\Time Series 1\Data"; 
 ods listing gpath = "%sysfunc(pathname(work))";
Data LWFETSP.CPI; 
input year cpi @@; 
** Compute your inflation index here **;
Inflation = dif(cpi)/lag(cpi)*100;
mean = 3.3042634; * This is just so I can add the mean trend line for easy comparison;
/*	above_0_cpi_infaltion = cpi_inflation + 10.51; * I was trying to adjust for large variation. THIS IS NOT NECESSARY!;
	log_cpi_inflation = log(above_0_cpi_infaltion); * This is taking the log of the adjust inflation;
*/
cards;
1913     9.9   1914    10.0   1915    10.1   1916    10.9   1917    12.8
1918    15.1   1919    17.3   1920    20.0   1921    17.9   1922    16.8
1923    17.1   1924    17.1   1925    17.5   1926    17.7   1927    17.4
1928    17.1   1929    17.1   1930    16.7   1931    15.2   1932    13.7
1933    13.0   1934    13.4   1935    13.7   1936    13.9   1937    14.4
1938    14.1   1939    13.9   1940    14.0   1941    14.7   1942    16.3
1943    17.3   1944    17.6   1945    18.0   1946    19.5   1947    22.3
1948    24.1   1949    23.8   1950    24.1   1951    26.0   1952    26.5
1953    26.7   1954    26.9   1955    26.8   1956    27.2   1957    28.1
1958    28.9   1959    29.1   1960    29.6   1961    29.9   1962    30.2
1963    30.6   1964    31.0   1965    31.5   1966    32.4   1967    33.4
1968    34.8   1969    36.7   1970    38.8   1971    40.5   1972    41.8
1973    44.4   1974    49.3   1975    53.8   1976    56.9   1977    60.6
1978    65.2   1979    72.6   1980    82.4   1981    90.9   1982    96.5
1983    99.6   1984   103.9   1985   107.6   1986   109.6   1987   113.6
1988   118.3   1989   124.0   1990   130.7   1991   136.2   1992   140.3
1993   144.5   1994   148.2   1995   152.4   1996   156.9   1997   160.5
1998   163.0   1999   166.6   2000   172.2   2001   177.1   2002   179.9
2003   184.0   2004   188.9   2005   195.3   2006   201.6   2007   207.3
2008   215.3   2009   214.5   2010   218.1   2011   224.9   2012   229.6
2013   233.0   2014   236.7
  ;
  run;
proc contents nods data=LWFETSP._all_;
proc contents data=LWFETSP.CPI; 
run; 
/********************************* RUNNING MODELS WITH TRAINING SET *************************/
/*
data training validation;
	set LWFETSP.CPI;
	if year < 2012 then output training;
	if year > 2011 then output validation;
run;
*/

/***********************************************************************************************/

/*********************************** without prediction split ***************************************/

proc means data = LWFETSP.CPI min max mean; 
	var Inflation;
run;

proc sgplot data = LWFETSP.CPI;
	scatter y = Inflation x = year;
	series y = Inflation x = year;
	series y = mean x=year;
run;
/* This part is unnecessary. I was plotting the new, adjust data 
proc sgplot data = LWFETSP.CPI;
	scatter y = log_cpi_inflation x = year;
	series y = log_cpi_inflation x = year;
run;
*/


/* There is a lot more variation before 1960. After 1990, the variation is very small
	from year to year with inflation. There are significant levels of deflation during 
	the Great Depression as well as period of high inflation during the ...
*/

/* Ran ARIMA on the original data with no MA or AR just to see trends */

proc arima data = lwfetsp.cpi plots=all;
	identify var =Inflation nlags = 15 ;
run;
quit;


/* Based on initial data, I chose to run a AR(2) first. Th results showed no correlation between the residuals, therefore
	we had white noise (good!). However, there seemed to possibly be a spike at lag 15 which led me to try at AR(1 2 15)*/
proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate  p=2 ml; *AR(2);
	forecast lead = 12 id = year out = resultsAR;
run;

proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate p = (1 2 5) ml; *AR(1,2,15);
quit;

/* I always do a 1 step down model just to see if there is a change from the AR(2) model */
proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate p = 1 ml; *AR(1);
quit;

/* AR(3) and AR(4) are not useful. They only have significant values at the mean, lag 1, and sometimes lag 2. */
proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate p = 3 ml; 
quit;

/* MA models */

/* MA(1) does not have white noise residuals */
proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate q = 1; *MA(1);
quit;
proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate q = 3; *MA(2);
	forecast lead = 12 id = year out = resultsMA;
quit;

proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate q = ( 1 2 15); *MA(2);
quit;
proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate q = ( 1 2 14 15); *MA(2);
quit;

/* Both ARMA */

proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate p=1 q=1; *ARMA(1,1);
	forecast lead = 12 id = year out = results;
quit;
proc export data = results	
					outfile = 'C:\Users\Owner\Desktop\MSA\Time Series 1\Homework\ForecastARMA.xlsx'
					DBMS = xlsx Replace;
run;

proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate p=2 q=1; *ARMA(2,1);
quit;

proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate p=3 q=1; *ARMA(2,1);
quit;
proc arima data = lwfetsp.cpi plots=all;
	identify var = Inflation nlags = 15 noprint;
	estimate p=2 q=3; *ARMA(2,1);
quit;
