ods listing gpath = "%sysfunc(pathname(work))";
options ls=76 nodate; title "Time Series Example 1";
data A;  input date $ Y @@; cards;
Jan82 10     Apr82 30     Jul82 60    Oct82  40
Jan83 50     Feb83 20     Mar83 35
 ; 
proc sort data=A; by date; 
proc print data=a;
proc sgplot; 
series Y=Y X=date/markers;
Title "Date without Format";  
run;

** Same thing WITH informat (no format) **; 

data A;  input date : monyy. Y @@; 
cards;
Jan82 10     Apr82 30     Jul82 60    Oct82  40
Jan83 50     Feb83 20     Mar83 35
 ; 
proc sort data=A; by date; 
proc print data=a;run; 
proc sgplot; 
series Y=Y X=date;
Title "Date without Format";  
run;

** Same thing with informat AND format **; 

data A;  input date : monyy. Y @@; 
  format date mmddyy.; 
* format date monyy.; 
* format date date9.; 
* format date worddate.; 
* format date weekday.; 
* format date weekdate.; 
cards;
Jan82 10     Apr82 30     Jul82 60    Oct82  40
Jan83 50     Feb83 20     Mar83 35
 ; 
proc sort data=A; by date; 
proc print data=a; run; 
proc sgplot; 
scatter Y=Y X=date;
Title "Date with Format";  
run;

** Creating dates **; 
data dates; 
 put _all_; 
input Y @@; 
date=intnx("month",date,1); 
put _all_ /;
retain date "15Jan2012"d;
format date date7.; 
cards; 
1 2 3 4 5 6 7 8 9 10 11 12
 ; 
proc print data=dates; 
Title "Initialize in mid January";
run; 

** What is default century? **; 

data B;
Diff = '01jan80'D-'13nov1979'd; dec1925='31dec1925'd; dec2025="31Dec2025"d;
dec25='31dec25'D;  ** Dec. 1925 < Jan. 1926 <=  Dec. 2025 < Jan. 2026  Pick Dec. 2025 **; 
jan26='01jan26'D;  ** this (1926) begins default century. Pick Jan 1926 **; 
proc print data=B; 
proc print data=B; 
format dec1925 dec2025 dec25 jan26 monyy7.;
run; 


data c; array date(3);
input x date7. ;
do i=1 to 3; twoi=2*i; date(i) =
intnx('month','01jan1912'd,twoi); end;
cards;
01feb60
 ; 
proc print data=c; run; 
proc print data=c; format x  date1-date3 date7.;run; 

** suppose someone sends you data with date as a character **; 

Data character; length date $9 ; 
input date $ @@; 
cards; 
01Jan1935  15Mar82 12Nov15
 ; 
Proc sort data=character; 
Proc print data=character; run; 

data next; set character; newdate= input(date, date9.);
newdate2 = newdate; format newdate monyy7.;
proc sort; by date; proc print; run; 
proc sort; by newdate2; proc print; run; 
****** END MON. ORANGE *********;
** Suppose you are missing a few dates **; 

Data Amazon;
** Amazon.com prices and volume from Yahoo finance **; 
input mon $ day $ year $ open high low close volume;
string = compress(day||mon||year); 
date=input(string,date9.); drop string; 
day=weekday(date);
format date date9.;  keep high low close volume date; 
cards; 
Jul 15 2015	463.04	464.70	460.20	461.19	2973300	461.19
Jul 14 2015	462.32	469.60	458.16	465.57	4722500	465.57
Jul 13 2015	448.29	457.87	447.54	455.57	3935600	455.57
Jul 10 2015	440.49	444.72	439.00	443.51	2397200	443.51
Jul 9 2015	434.90	438.72	434.15	434.39	2262900	434.39
Jul 8 2015	434.35	435.99	428.83	429.70	2375300	429.70
Jul 7 2015	435.68	437.73	425.57	436.72	3102300	436.72
Jul 6 2015	435.23	439.73	433.52	436.04	1899200	436.04
Jul 2 2015	437.00	438.20	433.48	437.71	1337200	437.71
Jul 1 2015	439.35	440.00	435.58	437.39	1973400	437.39
Jun 30 2015	434.20	435.57	430.46	434.09	2574200	434.09
Jun 29 2015	434.98	437.00	429.00	429.86	2709400	429.86
Jun 26 2015	441.76	443.49	435.06	438.10	2529500	438.10
Jun 25 2015	438.07	443.47	436.39	440.10	2235600	440.10
Jun 24 2015	444.97	446.47	440.23	440.84	2614400	440.84
Jun 23 2015	435.59	447.04	433.69	445.99	3209400	445.99
Jun 22 2015	437.00	439.24	434.18	436.29	1765500	436.29
Jun 19 2015	440.26	444.99	433.24	434.92	4481100	434.92
Jun 18 2015	430.30	439.73	429.41	439.39	3369700	439.39
Jun 17 2015	428.36	431.35	424.75	427.81	2184100	427.81
Jun 16 2015	424.15	427.97	422.67	427.26	2296400	427.26
Jun 15 2015	427.66	428.05	422.64	423.67	2041900	423.67
Jun 12 2015	431.25	432.36	428.26	429.92	2050200	429.92
Jun 11 2015	432.29	438.89	431.47	432.97	2917100	432.97
Jun 10 2015	426.46	432.20	425.66	430.77	2166500	430.77
Jun 9 2015	422.96	427.49	419.14	425.48	2274600	425.48
Jun 8 2015	425.62	426.80	421.43	423.50	2166900	423.50
Jun 5 2015	429.66	430.80	426.50	426.95	1903100	426.95
Jun 4 2015	434.40	436.76	429.26	430.78	2499700	430.78
Jun 3 2015	434.40	438.39	432.75	436.59	2720800	436.59
Jun 2 2015	430.07	433.23	426.25	430.99	1668900	430.99
Jun 1 2015	430.40	433.16	426.20	430.92	2250000	430.92
May 29 2015	427.23	432.50	427.23	429.23	3008600	429.23
May 28 2015	429.71	431.35	425.47	426.57	1907800	426.57
May 27 2015	427.45	431.85	425.01	431.42	2221400	431.42
May 26 2015	426.20	427.00	422.00	425.47	2238200	425.47
May 22 2015	431.55	432.44	427.61	427.63	2018600	427.63
May 21 2015	428.00	436.90	428.00	431.63	4113200	431.63
May 20 2015	420.60	427.10	418.36	423.86	2191000	423.86
May 19 2015	424.87	428.24	420.63	421.71	2464200	421.71
May 18 2015	426.00	427.27	421.46	425.24	2268700	425.24
May 15 2015	428.00	430.40	424.30	426.00	4226200	426.00
 ; 
proc sort data=amazon; by date; 
proc print data=amazon(obs=36 firstobs=33); 
Title "Amazon Stock Prices"; 
run; 
** Plot the data - high low and close **; 
proc sgplot data=amazon; 
series Y=low X=date/lineattrs=(pattern=solid); 
series Y=close X=date/lineattrs=(pattern=solid);
series Y=high X=date/lineattrs=(pattern=solid) markers;  
refline "03jul2015"d/axis=X; 
refline "25may2015"d/axis=X; 
Title2 "Showing Stock Market Closures"; 
run; 
****** END BLUE MONDAY ******;
** Generate the associated weeday dates (skip weekends) **; 
data dates; retain date "15May2015"d; 
format date date9.; drop i; 
do i=1 to 70; 
date = intnx("weekday",date,1); 
if date <= "15Jul2015"d then output; 
end; 
proc print data=dates(obs=38 firstobs=33); 
Title2 ; 
run; 
data all; merge amazon dates; by date; 
proc print data=all(obs=38 firstobs=33); run; 

** A faster way **; 
proc expand data=amazon out=new from=weekday to=weekday; 
id date; 
convert high low close volume/ method=none; 
run; 
proc print data=new(firstobs=33 obs=38); 
run; 

** Filling in using cubic splines (default) **; 

proc expand data=amazon out=new2 from=weekday; ** default: to= same as from= **; 
id date; 
convert close / method=spline; 
convert volume/ method=none; 
convert high low / method=step; 
run; 
proc print data=new2(obs=38 firstobs=33); 
run; 

