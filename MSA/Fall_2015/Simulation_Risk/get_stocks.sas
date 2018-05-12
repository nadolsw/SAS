/*******************************************************************************
 *  This macro merges the stock prices and returns of multiple runs of the     * 
 *  "download" macro. It then cleans the work library by deleting unneeded     *
 *  data sets.                                                                 *
 *                                                                             *
 * INPUTS                                                                      *
 *    SYMBOL: One or more stock symbols, e.g. AAPL                             *
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
 * A dataset called stocks.sas7bdat holding the date, the daily returns,       *
 * and optionally the price of all the stocks requested.                       *
 *                                                                             *
 * NOTES                                                                       *
 * This macro is based on the original work of Richard A. DeVenezia            *
 * Later added on to by Kostas Kyriakoulis and Aric LaBarr                     *
 *******************************************************************************/

%macro get_stocks(stock_list,start_date,end_date,keepPrice=0);
	%do i = 1 %to &n_stocks;
		%download(%scan(&stock_list,&i),&start_date,&end_date,keepPrice=&keepPrice,tranformed_name=%scan(&stock_list,&i));
	%end;

	data stocks;
		merge &stock_list;
		by Date;
	run;

	proc datasets noprint;
		delete &stock_list;
	run;
	quit;

%mend;


