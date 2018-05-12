/**This code generates Elasticity and Cross-Elasticity values using 
the two-point estimatation method and the log-log OLS regression for 
two products that have 26 weeks of sales data**/

*********************************************************************
/**Generate log values of quantity and price and compute Elasticity
and Cross-Elasticity values using the Two-Point Estimation Method**/
*********************************************************************;
data invoices;
 input week quantity1 price1 price2 promotion1 promotion2 ;
 format Price2 Price1 dollar10.2 ;
 logq1 = log(quantity1) ;
 logp1 = log(price1) ;
 logp2 = log(price2) ;
 lagp1 = lag(price1) ;
 lagp2 = lag(price2) ;
 lagq1 = lag(quantity1) ;
 if price1 - lagp1 ne 0
 then own = (mean(price1, lagp1)/mean(quantity1, lagq1))*((quantity1-
lagq1)/(price1-lagp1)) ;
 else own = . ;
 if price2 - lagp2 ne 0
 then cross = (mean(price2,lagp2)/mean(quantity1, lagq1))*((quantity1-
lagq1)/(price2-lagp2)) ;
 else cross = . ;
 datalines;
 1 70 7.50 7.00 0 0
2 75 7.30 7.15 0 0
3 75 7.25 7.15 0 0
4 78 7.25 7.15 0 0
5 100 6.50 7.20 1 0
6 120 6.50 7.20 1 0
7 95 6.50 7.25 1 0
8 115 6.50 7.25 1 0
9 78 7.05 7.25 0 0
10 85 7.05 7.25 0 1
11 88 7.05 7.30 0 1
12 84 7.05 7.30 0 1
13 90 7.05 7.30 0 1
14 86 7.05 7.40 0 0
15 95 7.00 7.40 0 0
16 88 7.00 7.40 0 0
17 105 6.90 7.40 0 0
18 100 6.90 7.45 0 1
19 108 6.90 7.45 0 1
20 95 6.90 7.50 0 1
21 98 6.90 7.50 0 1
22 130 6.45 7.50 1 0
23 125 6.45 7.70 1 0
24 133 6.45 7.75 1 0
25 128 6.45 8.00 1 0
26 131 6.45 8.00 1 0
;
run ;

proc format ;
 value undefmt . = '*' other = [8.2] ;
title 'Raw Data' ;

footnote "Note: '*' indicates that elasticity value cannot be estimated due to no
price change" ;
proc report data=invoices FORMCHAR='_' SPLIT='*' nowindows headline headskip ;
 column week quantity1 price1 price2 promotion1 promotion2 own cross;
 define week / '**Week' group center;
 define quantity1 / '*Product A*Quantity' center;
 define price1 / '*Product A*Price' center;
 define price2 /'*Product B*Price' center;
 define promotion1/ '*Product A*Promotion #1' center;
 define promotion2/'*Product A*Promotion #2' center ;
 define own / 'Point*Elasticity*(own)' center format=undefmt.;
 define cross/'Point*Elasticity*(cross)' center format=undefmt.;
run;
footnote;
%annomac;
data anno;
 %system(2, 2)
 %label(24,33,'|- Promo. 1 -|',*,0,0,1.25,duplex);
 %label(6.5,33,'| Promo. 1 |',*,0,0,1.25,duplex);
 %label(19.5,33,'| Promo. 2 |',*,0,0,1.25,duplex);
 %label(11.5,33,'| Promo. 2 |',*,0,0,1.25,duplex);
run;

************************************************************************
/** Generate a Graph to show the relationship between prices and quantity 
of productA **/
************************************************************************ ;
goptions reset=all ftext=SWISS htext=2.5 ;
axis1 order=(25 to 150 by 25) minor=none label=(angle=90 'Quantity (units)' )
offset=(1) ;
axis2 order=(6.25 to 8.25 by .5) minor=(number=1) label=(angle=90 'Price ($)')
offset=(1);
axis3 order=(0 to 27 by 3) minor=(number=2) label=('Week') offset=(1) ;
symbol1 color=black i=join value=circle height=2 width=2 ;
symbol2 color=black i=join value=square height=2 width=2 ;
symbol3 color=black i=join value=triangle height=2 width=2 ;
legend1 label=none mode=reserve position=(top center outside) value=('Quantity
A' ) shape=symbol(5,1) ;
legend2 label=none mode=reserve position=(top center outside) value=('Price A'
'Price B') shape=symbol(3,1) ;
proc gplot data=invoices ;
 plot quantity1*week=1 /overlay annotate=anno legend=legend1 vaxis=axis1
haxis=axis3 ;
 plot2 price1*week=2 price2*week=3 /overlay legend=legend2 vaxis=axis2 ;
run ;

************************************************************************
/** Generate a graph to show the price and quantity of Product A with
price of product B **/
************************************************************************ ;
proc reg data=invoices noprint ;
 model quantity1=price1 ;
 output out=yhat1 predicted=yhat1 ;
run ;
proc reg data=invoices noprint ;
 model quantity1=price2 ;
 output out=yhat2 predicted=yhat2 ;
run ;

proc sql;
 create table forplot as
 select a.week,
a.quantity1,
a.price1,
yhat1,
a.price2,
yhat2
 from invoices a, yhat1 b, yhat2 c
 where a.week = b.week = c.week ;
quit ;
goptions reset=all ftext=SWISS htext=2.5 ;
axis1 order=(0 to 150 by 25) minor=none label=(angle=90 'Quantity of A' )
offset=(1) ;
axis2 order=(6.25 to 8.25 by .5) minor=(number=1) label=('Price ($)')
offset=(5) ;
symbol1 color=black value=circle height=2 width=2 ;
symbol2 color=black value=square height=2 width=2 ;
symbol3 color=black i=join line=7 height=2 width=2 ;
symbol4 color=black i=join line=2 height=2 width=2 ;
legend1 label=none position=(top center outside) value=('Product A' 'Product
B') shape=symbol(5,1) ;
proc gplot data=forplot ;
 plot quantity1*price1=1 quantity1*price2=2 yhat1*price1=3 yhat2*price2=4 /overlay
legend=legend1 vaxis=axis1 haxis=axis2 ;
run ;

************************************************************************
/** Estimate elasticity based on only quantity and price using linear 
regression model for product A **/
************************************************************************ ;
ods listing close;
proc glm data=invoices ;
 model quantity1 = price1 ;
 ods output
 ParameterEstimates = pe1 ;
run ;
ods listing;
proc sql noprint;
select mean (quantity1) into: mean_quantity1 from invoices ;
select mean (price1) into: mean_price1 from invoices ;
quit ;
data pe1 ;
set pe1 ;
mean_quantity = &mean_quantity1 ;
mean_price = &mean_price1 ;
 if parameter ne "Intercept" then elasticity = estimate * (&mean_price1 /
&mean_quantity1) ;
run ;

************************************************************************
/** Estimate elasticity based on only quantity and price using log-log 
regression model for product A **/
************************************************************************ ;
ods listing close;
proc glm data=invoices;
 model logq1 = logp1 ;
 ods output
 ParameterEstimates = pe2 ;
run;
ods listing;
data pe;
 set pe1 pe2
 data pe;
 set pe1 pe2;
run;
proc print data=pe noobs;
 where parameter ne 'Intercept';
 var Parameter Estimate StdErr tValue Probt mean_quantity mean_price elasticity;
run;

******************************************************************************
/** Estimate cross-elasticity using linear regression model for product A **/
****************************************************************************** ;
ods listing close;
proc glm data=invoices ;
 model quantity1 = price1 price2 ;
 ods output
 ParameterEstimates = ce1 ;
run ;
ods listing;
proc sql noprint;
select mean (price2) into: mean_price2 from invoices ;
quit ;
data ce1 ;
set ce1 ;
 if parameter eq "price2" then do;
 mean_quantity = &mean_quantity1 ;
 mean_price = &mean_price2 ;
 elasticity = estimate * (&mean_price2 / &mean_quantity1) ;
 end;
run ;
******************************************************************************
/** Estimate cross-elasticity using log-log regression model for product A **/
****************************************************************************** ;
ods listing close;
proc glm data=invoices;
 model logq1 = logp1 logp2 ;
 ods output
 ParameterEstimates = ce2 ;
run;
ods listing;
data ce;
 set ce1 ce2;
run;
proc print data=ce noobs;
 where parameter ne 'Intercept';
 var Parameter Estimate StdErr tValue Probt mean_quantity mean_price elasticity;
run;
************************************************************************
/** Estimate elasticity based on quantity, price, promotions of product
 A and price of product B using log-log regression model **/
************************************************************************ ;
ods listing close;
proc glm data=invoices ;
 model logq1 = logp1 logp2 promotion1 promotion2 logp1*promotion1 logp1*promotion2
;
 ods output
 OverallANOVA = OverallANOVA3
 FitStatistics = FitStatistics3
 ParameterEstimates = pe3 ;
run ;
ods listing;
proc print data=OverallANOVA3 noobs ;
proc print data=FitStatistics3 noobs;
proc print data=pe3 noobs;
run ;
