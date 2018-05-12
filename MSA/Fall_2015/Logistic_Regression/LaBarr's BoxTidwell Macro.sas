%macro logitassump(target, vars, data, outfinal);
  %let k=1;
  %let dep = %scan(&vars, &k);
  %do %while("&dep" NE "");
  	data testing;
		set &data;
		x = &dep;
		xlogx = &dep*log(&dep);
		label x = "&dep" xlogx = "Box-Tidwell &dep";
	run;
	title "Model for only &dep";
    proc logistic data=testing;
      model &target = x  / parmlabel;
	  ods output ParameterEstimates = Work.BetaI&k;
    run;
    title "Model for both &dep and log(&dep)";
    proc logistic data=testing;
      model &target = &dep xlogx  / parmlabel;
	  ods output ParameterEstimates = Work.BetaL&k;
    run;
	data Beta_&dep;
      set BetaI&k BetaL&k; 
    run;
	data _null_;
		set Beta_&dep;
		if Variable ne 'x' then delete;
		call symput('beta', Estimate);
	run;
	data _null_;
		set Beta_&dep;
		if Variable ne 'xlogx' then delete;
		call symput('delta', Estimate);
	run;
	data BetaL&k;
		set BetaL&k;
		if Variable = 'xlogx' then Exponent = 1 + (&delta/&beta);
		else Exponent = .;
	run;
    %let k = %eval(&k + 1);
    %let dep = %scan(&vars, &k);
  %end;
  %if "&outfinal" NE "" %then 
  %do;
    data &outfinal;
      set 
      %do i = 1 %to &k - 1;
        BetaL&i
      %end; 
      ;
	  if Variable ne 'xlogx' then delete;
	  keep ProbChiSq Exponent Label;
    run;	  
    %let k = %eval(&k - 1);
    proc datasets;
      delete BetaI1 - BetaI&k;
    run;
	quit;
	proc datasets;
      delete BetaL1 - BetaL&k;
    run;
	quit;
  %end;
  %else 
  %do;
     %put no dataset name was provided, files are not combined;
  %end;
%mend;

%logitassump(response, vars, data, output)
