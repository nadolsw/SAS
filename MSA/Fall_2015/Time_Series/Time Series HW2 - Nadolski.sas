** CPI from Table 24 of Bureau of Labor Statistics (baseline 100 is 1982-84) 
   report found at   http://www.bls.gov/cpi/cpid1507.pdf  **; 

libname LWFETSP "C:\TimeSeriesData"; 
Data LWFETSP.CPI; 
input year cpi @@; 
** Compute your inflation index here **; 
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
proc contents nods data=LWFETSP._all_;
proc contents data=LWFETSP.CPI; 
run; 

***CREATE LAG CPI, DIFF CPI, AND INFLATION EACH YEAR***;
data work.CPI;
	set lwfetsp.Cpi;
	LAG_CPI=lag1(CPI);
	DIFF_CPI=CPI-LAG_CPI;
	INF=(DIFF_CPI/LAG_CPI)*100;
	inf_lag1=lag1(inf);
	inf_lag2=lag2(inf);
run;

proc sgplot data=CPI;
	scatter y=INF x=year;
run;

***SIGNIFICANT DEFLATION IN 1920's & 1930's - SIGNIFICANT INFLATION IN 1910's, 1940's, 1970's***;
proc reg data=CPI;
	model INF = year;
	output out=out1 predicted=p residual=r;
run;

***DEFLATION IN 1921-1922, 1927-1928, 1930-1933, 1938-1939, 1949, 1955, 2009***; 
proc print data=cpi;
	var year inf;
	where inf<0;
run;

***SIGNIFICANT INFLATION IN 1917-1920, 1942, 1947, 1974, 1979, 1980-1981***;
proc print data=cpi;
	var year inf;
	where inf>10;
run;

***HISTORIC AVERAGE INFLATION IS 3.3% PER YEAR***;
proc means data=CPI;
	var INF;
run;

***TEST FOR WHITENOISE***;
proc timeseries data=cpi print=(descstats) plot=(series corr acf pacf iacf wn);
	var inf;
run;

***FIT AR MODELS***;
proc arima data=cpi;
	identify var=inf;
	estimate p=1 ml;
run;

proc arima data=cpi;
	identify var=inf;
	estimate p=2 ml;
run;

proc arima data=cpi;
	identify var=inf;
	estimate p=3 ml;
run;

proc arima data=cpi;
	identify var=inf;
	estimate p=4 ml;
run;

***FIT MA MODELS***;
proc arima data=cpi;
	identify var=inf;
	estimate q=1 ml;
run;

proc arima data=cpi;
	identify var=inf;
	estimate q=2 ml;
run;

proc arima data=cpi;
	identify var=inf;
	estimate q=3 ml;
run;

proc arima data=cpi;
	identify var=inf;
	estimate q=4 ml;
run;

***FIT ARMA MODELS***;
proc arima data=cpi;
	identify var=inf;
	estimate p=1 q=1 ml;
run;

*ESTIMATES DID NOT CONVERGE?*;
proc arima data=cpi;
	identify var=inf;
	estimate p=2 q=2 ml;
run;
