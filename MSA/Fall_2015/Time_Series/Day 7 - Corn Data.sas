ods listing gpath = "%sysfunc(pathname(work))";
%let break=1942.3;  ** change to modern era determined by PROC NLIN; 
*  Corn yields, Bushels per Acre yearly
   Source: NASS webpage 
   http://quickstats.nass.usda.gov/results/90C69DEC-38D6-31B4-9953-4C6EB5E82D79?pivot=short_desc
*************************************************************************************************; 
ods listing gpath = "%sysfunc(pathname(work))";

 ***(1) Input the data, sort by year, and lag ***; 

Data corn; 
input year 1-4 BPA 65-70; 
 label BPA="Corn: Bushels per Acre"; 
*23456789 123456789 123456789 123456789 123456789 123456789 12456789 ; 
 cards;
2026                                                               .
2025                                                               .
2024                                                               .
2023                                                               .
2022                                                               .
2021                                                               .
2020                                                               .
2019                                                               .
2018                                                               .
2017                                                               .
2016                                                               .
2015                                                               .
2014	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	171.0
2013	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	158.1
2012	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	123.1
2011	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	146.8
2010	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	152.6
2009	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	164.4
2008	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	153.3
2007	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	150.7
2006	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	149.1
2005	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	147.9
2004	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	160.3
2003	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	142.2
2002	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	129.3
2001	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	138.2
2000	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	136.9
1999	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	133.8
1998	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	134.4
1997	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	126.7
1996	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	127.1
1995	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	113.5
1994	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	138.6
1993	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	100.7
1992	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	131.5
1991	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	108.6
1990	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	118.5
1989	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	116.3
1988	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	84.6
1987	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	119.8
1986	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	119.4
1985	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	118
1984	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	106.7
1983	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	81.1
1982	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	113.2
1981	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	108.9
1980	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	91
1979	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	109.5
1978	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	101
1977	 		 	 	0	    CORN	TOTAL	NOT SPECIFIED	90.8
1976	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	88
1975	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	86.4
1974	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	71.9
1973	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	91.3
1972	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	97
1971	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	88.1
1970	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	72.4
1969	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	85.9
1968	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	79.5
1967	 		 	 	0	    CORN	TOTAL	NOT SPECIFIED	80.1
1966	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	73.1
1965	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	74.1
1964	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	62.9
1963	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	67.9
1962	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	64.7
1961	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	62.4
1960                    0                                       54.7
1959                    0		CORN	TOTAL	NOT SPECIFIED	53.1
1958	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	52.8
1957	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	48.3
1956	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	47.4
1955	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	42
1954	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	39.4
1953	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	40.7
1952	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	41.8
1951	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	36.9
1950	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	38.2
1949	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	38.2
1948	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	43
1947	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.6
1946	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	37.2
1945	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	33.1
1944	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	33
1943	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	32.6
 ; 
      *** (1) Sort, compute lag and lagged differences; 
proc sort data=corn; 
  by  year;  
data corn; set corn; 
  L_corn=lag(BPA); D_corn=BPA-L_corn; 
  Diff_Lag1 = lag(D_corn); Diff_Lag2=lag2(D_corn); 
proc print data=corn ; 
Title "Corn yields, bushels per acre"; run;

   ***(2) Plot the data ***; 
  ods graphics; 
     Title "U.S. Corn Yields"; 
     Title2 "Source NASS Quick Facts";
 proc sgplot data=corn;
  series X=year Y=BPA/lineattrs=(color=red); 
  reg X=year Y=BPA; 
 run; quit; 

  ods graphics off; ** reg will run faster **; 

   *** (3) Check for augmenting lags ***;
 
proc reg  data=corn;  
  model D_corn=L_corn year Diff_Lag1 Diff_Lag2/SS1;
  No_Augment: test Diff_Lag1=0, Diff_Lag2=0; 
  title "Check for augmenting lags"; 
run; 

proc reg data=corn;   
  model D_corn=L_corn year;
  title "Compare t to case 3 critical values"; 
  title2 "Do not trust these p-values";
  title3 "Note that rho-1 estimate is about -1";  
run; quit; 

  ods graphics; 

   *** (4) Correct Unit Root Tests ***; 
proc arima data=corn plots=forecast(forecast); 
  identify var = BPA stationarity = (adf=0); run;  
  identify var = BPA crosscor=(year); ** need to pull in potential predictors **; 
  estimate ml input=(year);  ** no evidence of autocorrelation!  **; 
  forecast lead=12 id=year out=outarima2; 
  title "Correct unit root tests"; 
 run; quit;  

  *** OPTIONAL: Check for precipitation effect, current & past years ***; 

/* data from 

http://www.ncdc.noaa.gov/cag/time-series/us/110/00/pcp/12/04/
  1895-2015.csv?base_prd=true&firstbaseyear=1901&lastbaseyear=2000
 

Contiguous U.S., Precipitation, May-April
Units: Inches
Base Period: 1901-2000
Date,Value,Anomaly  */


Data precip; 
input year 1-4 inches 8-12; year=year-1; ** <----- **; 
if year > 1942 then output; * modern era only ; 
** Rainfall through April affects previous year's crop **;
** Rainfalls are "anomalies," i.e. deviations from some base year rain **;  
cards; 
189604,28.29,-1.66
189704,31.54,1.59
189804,27.00,-2.95
189904,30.54,0.59
190004,29.17,-0.78
190104,29.62,-0.33
190204,27.45,-2.50
190304,32.17,2.22
190404,28.52,-1.43
190504,28.76,-1.19
190604,31.92,1.97
190704,32.59,2.64
190804,31.10,1.15
190904,30.41,0.46
191004,28.42,-1.53
191104,26.70,-3.25
191204,30.97,1.02
191304,29.71,-0.24
191404,29.19,-0.76
191504,29.00,-0.95
191604,33.20,3.25
191704,28.80,-1.15
191804,24.99,-4.96
191904,29.65,-0.30
192004,31.99,2.04
192104,30.59,0.64
192204,30.60,0.65
192304,28.44,-1.51
192404,30.43,0.48
192504,25.94,-4.01
192604,28.13,-1.82
192704,32.17,2.22
192804,30.36,0.41
192904,31.19,1.24
193004,28.16,-1.79
193104,25.23,-4.72
193204,29.67,-0.28
193304,29.71,-0.24
193404,25.88,-4.07
193504,27.78,-2.17
193604,29.51,-0.44
193704,28.38,-1.57
193804,30.32,0.37
193904,28.88,-1.07
194004,26.90,-3.05
194104,29.14,-0.81
194204,32.74,2.79
194304,30.94,0.99
194404,29.19,-0.76
194504,30.47,0.52
194604,31.24,1.29
194704,30.90,0.95
194804,30.67,0.72
194904,30.75,0.80
195004,30.34,0.39
195104,30.27,0.32
195204,31.46,1.51
195304,26.84,-3.11
195404,26.63,-3.32
195504,25.94,-4.01
195604,28.14,-1.81
195704,26.97,-2.98
195804,33.93,3.98
195904,28.62,-1.33
196004,30.90,0.95
196104,29.35,-0.60
196204,30.54,0.59
196304,27.66,-2.29
196404,27.74,-2.21
196504,29.33,-0.62
196604,29.42,-0.53
196704,26.82,-3.13
196804,29.71,-0.24
196904,31.85,1.90
197004,30.08,0.13
197104,28.86,-1.09
197204,30.51,0.56
197304,34.95,5.00
197404,33.20,3.25
197504,31.90,1.95
197604,30.25,0.30
197704,25.98,-3.97
197804,32.01,2.06
197904,32.17,2.22
198004,31.31,1.36
198104,25.48,-4.47
198204,32.51,2.56
198304,35.42,5.47
198404,32.26,2.31
198504,30.21,0.26
198604,30.49,0.54
198704,31.52,1.57
198804,28.23,-1.72
198904,26.81,-3.14
199004,30.96,1.01
199104,32.19,2.24
199204,30.72,0.77
199304,33.44,3.49
199404,31.04,1.09
199504,31.65,1.70
199604,31.60,1.65
199704,34.82,4.87
199804,33.71,3.76
199904,31.52,1.57
200004,27.38,-2.57
200104,27.93,-2.02
200204,28.47,-1.48
200304,29.88,-0.07
200404,30.43,0.48
200504,33.99,4.04
200604,29.39,-0.56
200704,29.62,-0.33
200804,30.14,0.19
200904,30.18,0.23
201004,32.93,2.98
201104,32.02,2.07
201204,29.18,-0.77
201304,27.50,-2.45
201404,30.91,0.96
201504,30.50,0.55
 ; 
proc sort data=corn; by year; 
data both; merge corn precip; by year; lprecip=lag(inches); 
proc print data=both (obs=90 firstobs=50);  run; 
ods graphics off; 
proc reg data=both; 
model bpa = year inches/ ss1;
run; quit; 


** OPTIONAL show all historical data **; 
data more; 
input year @64 BPA; era="old"; 
*23456789 123456789 123456789 123456789 123456789 123456789 123456789;
cards; 
1942	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	35.4
1941	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	31.2
1940	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.9
1939	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.9
1938	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.8
1937	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.9
1936	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	18.6
1935	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.2
1934	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	18.7
1933	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	22.8
1932	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.5
1931	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.5
1930	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	20.5
1929	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	25.7
1928	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.3
1927	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.4
1926	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	25.7
1925	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.4
1924	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	22.1
1923	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.8
1922	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.3
1921	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.8
1920	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.9
1919	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.8
1918	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	23.9
1917	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.2
1916	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.1
1915	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.1
1914	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	25.8
1913	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	22.7
1912	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.1
1911	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.4
1910	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.9
1909	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.1
1908	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.9
1907	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.2
1906	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	31.7
1905	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	30.9
1904	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.2
1903	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.9
1902	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.5
1901	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	18.2
1900	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.1
1899	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28
1898	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.8
1897	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	25.4
1896	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	30
1895	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28
1894	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	20.2
1893	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	23.8
1892	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.7
1891	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.6
1890	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	22.1
1889	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.5
1888	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.1
1887	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	21.9
1886	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.1
1885	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.6
1884	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.3
1883	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.2
1882	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.5
1881	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	19.8
1880	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.3
1879	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	28.2
1878	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.2
1877	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	25.8
1876	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.7
1875	                0		CORN	TOTAL	NOT SPECIFIED	27.7
1874	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	22.2
1873	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	22.9
1872	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.4
1871	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	27.2
1870	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	29.3
1869	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	21.8
1868	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	26.2
1867	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.7
1866	 		 	 	0		CORN	TOTAL	NOT SPECIFIED	24.3
 ; 
 data all; set corn more;
 proc sort data=all; by year; 
 proc sgplot; 
 reg Y=BPA X=YEAR/group=era; 
 run; 



