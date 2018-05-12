/* Load Needed Macros, set library */
/*Macros can be found in Dr. Labarr's Sim and Risk page on Moodle*/
%include "C:\Users\Timothy\Google Drive\Simulation and Risk\download.sas";
%include "C:\Users\Timothy\Google Drive\Simulation and Risk\get_stocks.sas";
libname fin "C:\Users\Timothy\Google Drive\Financial Analytics\Datasets";

/*List of DJIA Components*/
/* 3M MMM, American Express	AXP, Apple AAPL, Boeing BA, Caterpillar	CAT
   Chevron CVX, Cisco Systems CSCO, Coca-Cola KO, DuPont DD, ExxonMobil XOM.
   General Electric GE, Goldman Sachs GS, The Home Depot HD, Intel INTC, IBM IBM,
   Johnson & Johnson JNJ, JPMorgan Chase JPM, McDonald's MCD, Merck MRK, 
   Microsoft MSFT, Nike NKE, Pfizer PFE, Procter & Gamble PG, Travelers TRV
   UnitedHealth Group UNH, United Technologies UTX, Verizon VZ, Visa V, Wal-Mart WMT,
   Walt Disney DIS */

/*Just Symbols (LM at lag 1)*/
/* MMM (49) AXP (108) AAPL (73) BA (111) CAT (37) CVX (206)
   CSCO (6) KO (217) DD (110) XOM (262) GE (197) GS (151) 
   HD (131) INTC (79) IBM (72) JNJ (116) JPM (307) MCD (73) 
   MRK (70) MSFT (49) NKE (64) PFE (80) PG (84) TRV (362)
   UNH (58) UTX (80) VZ (306) V (56) WMT (55) DIS (91) */


/* Get a Dataset with the Microsoft Stocks */
%let stocks = KO;

/* Count the Number of Stocks in the Portfolio */
%let n_stocks=%sysfunc(countw(&stocks));

/* Download Stocks */
%get_stocks(&stocks,01mar2006,29feb2016,keepPrice=1);

/* Reset the Format to Avoid SGPLOT Warnings Later On and create unique dataset */
data Stocks_&stocks;
  set Stocks;
  format Date date7.;
run; 

/*Look at LM score at lag 1*/
proc autoreg data=Stocks_&stocks all plots=none;
   model &stocks._r =/ archtest normal;
run;

/* Add 30 Observations for Forecasting at End of Series 
  (Dates will be wrong because they include weekends)*/
data fin.Stocks_&stocks(drop=i);
  set Stocks_&stocks end = eof;
  output;
  if eof then do i=1 to 30;
    date=date+1;
    &stocks._p=.;
	&stocks._r=.;
    output;
  end;
run;

/*Five stocks with the best LM at Lag 1*/
/* TRV (362)
   JPM (307)
   VZ (306)
   XOM (262)
   KO (217) */


