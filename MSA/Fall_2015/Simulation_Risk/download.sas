/*******************************************************************************
 *  This macro builds a URL that points to a Yahoo-created CSV file, with the  *
 *  stock data of interest. It then creates a SAS dataset that holds the stock *
 *  returns of the selected stock, during the selected period.                 *
 *                                                                             *
 * INPUTS                                                                      *
 *    SYMBOL: Stock symbol, e.g. AAPL                                          *
 *      From: "From" date, using the DATE9 format;                             *
 *             if empty, it defaults to last year's value                      *
 *        To: "To" date, using the DATE9 format;                               *
 *             if empty, it defaults to last year                              *
 * KeepPrice: Binary variable;                                                 *
 *            Set to 1 to keep both the original price and the daily returns   *
 *            in the output dataset.                                           *
 *            Set to 0 to create only one dataset with the daily returns.      *
 *                                                                             *
 * OUTPUT                                                                      *
 * A dataset with the same name as the stock symbol, e.g. appl.sas7bdat,       *
 * holding the date, the daily returns, and optionally the price.              *
 *                                                                             *
 * NOTES                                                                       *
 * This macro is based on the original work of Richard A. DeVenezia            *
 * Later added on to by Kostas Kyriakoulis and Aric LaBarr                     *
 *******************************************************************************/

%macro download(symbol,from,to,keepPrice=0,tranformed_name=);
/*Builde URL for CSV from Yahoo! Finance*/
data _null_;
  format s $128.;
  /*Handle "from" values*/
  if "&from" ^= "" then
    from = "&from"d;
  else
    from = intnx('year',today(),-1,'same');
  /*Handle "to" values*/
  if "&to" ^= "" then
    to = "&to"d;
  else
    to = today()-1;

  /*Disply the FROM, TO period in the log*/
  %put NOTE: FROM= date9. TO= date9.;

  /*Build the elements needed by the Yahoo URL*/
  to_d = day(to);
  to_m = month(to)-1;
  to_y = year(to);
  from_d = day(from);
  from_m = month(from)-1;
  from_y = year(from);
  /*Build the Yahoo URL*/
  s = catt("'http://ichart.finance.yahoo.com/table.csv?s=&symbol",
      '&d=',put(to_m,z2.),
      '&e=',to_d,
      '&f=',put(to_y,4.),
      '&g=d&a=',put(from_m,z2.),
      '&b=',from_d,
      '&c=',put(from_y,4.),
      '&ignore=.csv',
      "'");
  call symput("s",s);
  run;

  /*Display the URL value in the SAS log*/
  %put NOTE: &s;

  /*SAS Filename to point to the URL*/
  filename in url &s;

  /*Use PROC IMPORT to download and parse the CSV*/
  proc import file=in dbms=csv out=%left(%trim(&tranformed_name)) replace;
  run;

  /*Rename the adj_close variable*/
  data &tranformed_name(rename=(adj_close=&tranformed_name._p));
    set &tranformed_name(keep=date adj_close);
  run;

  /*Clear the filename to the url*/
  filename in clear;

  /*Ensure data are sorted*/
  proc sort data=&tranformed_name(keep=date &tranformed_name._p);
   by date;
  run;

  /*Create a dataset that holds the log returns*/
  data &tranformed_name;
    set &tranformed_name;
    &tranformed_name._r = log(&tranformed_name._p/lag(&tranformed_name._p));
  run;

   /*If requested, delete the actual prices*/
  %if &keepPrice = 0 %then %do;
    data &tranformed_name;
      set &tranformed_name(keep=date &tranformed_name._r);
    run;
  %end;

%mend;


