
libname WINADO "C:\Users\winado\Desktop\Trace";

/*Save dataset*/
/*data WINADO.TRACE;*/
/*	set trace;*/
/*run;*/

proc sort data=WINADO.TRACE;
	by label;
run;

/*known labels for each run*/
data solution;
/*	length run $ 7.;*/
	set WINADO.TRACE(keep=label);
	run+1;
/*	run='run_'||strip(put(S,$3.));*/
/*	drop S;*/
run;

data long1;
	set WINADO.TRACE;
	run+1;
	drop label;
run;

proc transpose data=long1 out=long2(drop=_name_) prefix=x;
	var F: ;
	by run;
run;

proc sql;
	create table long3 as
	select *
	from long2 t1
	left join WINADO.solution t2
	on t1.run=t2.run;
quit;

/*Long data for graphing*/
data long;
	set long3;
	by run;
	if first.run then t=0;
	t+1;
run;



/*Get all runs, one column per run on common time index t*/
proc transpose data=WINADO.TRACE out=transp(drop=_name_) prefix=run_;
	var F:;
run;

data wide;
	length t 8.;
	set transp;
	t+1;
run;

/*Normalize all curves to between 0 and 1*/
proc stdize data=wide out=wide_std method=range;
	var run:;
run;


proc sgplot data=wide;
	series x=t y=run_25;
	series x=t y=run_75;
	series x=t y=run_125;
	series x=t y=run_175;
run;


/*Grab list of all run names*/
proc contents data=wide_std out=cont(keep=name);
run;

%let base_run=run_1;
options mprint mlogic symbolgen;

proc sql noprint;
	select strip(name) into: run_list separated by " " from cont where name ne 't' and name ne "&base_run";
	select round(count(*)*0.25,1) into: max_lag from wide_std;
/*	select round(count(*)*0.19,1) into: lag_threshold from wide_std;*/
quit;

/*Delete any pre-existing xcorr_collector - only useful if program has previously been run in same session*/
proc delete data=xcorr_collector;


/*Use cross correlation function to identify optimal lag for alinging curves then shift each curve appropriately*/
%macro align_curves();
%do i=1 %to %sysfunc(countw(&run_list));
	%let this_run=%sysfunc(scan(&run_list,&i));

		proc timeseries data=wide_std outcrosscorr=crosscorr;
		   id t interval=day;
		   crossvar &base_run &this_run;
		   crosscorr / nlag=&max_lag; /*max lag is 25% of length of base series*/
		run;

		proc sql noprint;
			create table xcorr as
			select distinct _name_, _cross_, ccf, lag
			from crosscorr
			where _name_="&base_run"
			order by ccf desc;

			create table max_xcorr as
			select distinct input(substr(_cross_,5),8.) as run, lag
			from xcorr(obs=1);

			select lag into: lag from max_xcorr;
		quit;

/*		%if &lag > &lag_threshold %then %do;*/
/*			%let lag=0; */
			/*if lag is too large then don't shift the curve*/


		proc append base=xcorr_collector data=max_xcorr force;
		run;

		data &this_run;
			set wide_std(keep=t &this_run);
			where &this_run is not missing;
			t=t+&lag;
		run;

		data wide_std;
			merge &this_run wide_std(drop=&this_run);
			by t;
		run;
	%end;
%mend align_curves;

%align_curves;
/*Shifting curves is not necessary*/
 





data WINADO.WIDE_STD;
	set wide_std;
run;



/*Visualize true class labels*/
/*proc transpose data=WINADO.wide_std out=test prefix=x;*/
/*	var run:;*/
/*	by t;*/
/*run;*/
/**/
/*proc sort data=test;*/
/*	by _name_ t;*/
/*run;*/
/**/
/*data test;*/
/*	set test;*/
/*	run=input(substr(_name_,5),8.);*/
/*run;*/
/*Pad leading and trailing blanks with most recent value*/



libname WINADO "C:\Users\winado\Desktop\Trace";

/*Apply SAX - 25 discrete time units*/
%let SAX_units=11; /*Number of SAX time increments used to cover length of time t*/
%let SAX_symbols=10; /*Number of SAX symbols to use - basically the max 'height' of the SAX representation*/

proc sql noprint;
	select count(t) into: t_duration from WINADO.WIDE_STD;
quit;

%let SAX_unit_length=%sysevalf(&t_duration/&SAX_units); /*Number of time units in each SAX unit*/
%put &=SAX_unit_length;

/*Create mapping table from numeric value to SAX symbol*/
data SAX_lookup(drop=char_rank);
  input symbol $1. num 8.;
  num=0;
  output; 

  do num=1 to &SAX_symbols;
  	char_rank=rank(symbol)+1;
    symbol=byte(char_rank);
    output;
  end;
  datalines;
a
run;



data SAX_format;
	set SAX_lookup;
	retain fmtname '$SAX' type 'C';
	start=put(num,2.);
	label=symbol;
	keep fmtname start label type;
run;

proc format cntlin=SAX_format;
run;




data s_index(keep=s);
	length s i 8.;
	if _n_=1 then s=0;
	do s=1 to &SAX_units;
		do i=2 to &SAX_unit_length;
			output;
		end;
		output;
	end;
run;

data s_index;
	set s_index;
	t+1;
run;



proc contents data=WINADO.WIDE_STD out=cont(keep=name);
run;

proc sql noprint;
	select name into: run_list separated by " " from cont where name ne 't';
quit;

%macro apply_PAA;
proc sql;
	create table PAA as
	select *
	from WINADO.WIDE_STD t1
	left join s_index t2
	on t1.t=t2.t
	order by t;
quit;

proc sql;
	create table PAA(drop=dummy) as
	select distinct
		s,
/*		t,*/
/*		*,*/
		%do i=1 %to %sysfunc(countw(&run_list));
			%let this_run=%sysfunc(scan(&run_list,&i));
				round(avg(&this_run),0.1)*10 as PAA_&this_run,
		%end;
		(1) as dummy
	from PAA
	group by s
	order by s;
quit;
%mend apply_PAA;

%apply_PAA;




/*PAA DTW Distance*/
/*proc similarity data=PAA outsum=simmatrix;*/
/*   target PAA: / measure=sqrdev*/
/*              compress=(localpct=30 globalpct=30)*/
/*              expand=(localpct=30 globalpct=30);*/
/*run;*/
/**/
/**/
/*proc cluster data=simmatrix(drop=_status_) outtree=tree method=ward noprint;*/
/*   id _input_;*/
/*run;*/
/**/
/*proc tree data=tree horizontal ncl=4 out=cluster;*/
/*run;*/
/**/
/*proc sort data=cluster;*/
/*	by cluster _name_;*/
/*run;*/
/**/
/*data cluster;*/
/*	set cluster;*/
/*	run=input(scan(_name_,3,'_'),8.);*/
/*run;*/
/**/
/**/
/**/
/*proc transpose data=WINADO.wide_std out=test prefix=x;*/
/*	var run:;*/
/*	by t;*/
/*run;*/
/**/
/*proc sort data=test;*/
/*	by _name_ t;*/
/*run;*/
/**/
/*data test;*/
/*	set test;*/
/*	run=input(substr(_name_,5),8.);*/
/*run;*/
/**/
/**/
/*proc sql;*/
/*	create table merge as*/
/*	select **/
/*	from test t1*/
/*	left join cluster t2*/
/*	on t1.run=t2.run*/
/*	order by run, t;*/
/*quit;*/
/**/
/**/
/*proc sgplot data=merge(where=(cluster=1));*/
/*	series x=t y=x1 / group=run lineattrs=(color=blue);*/
/*run;*/
/**/
/*proc sgplot data=merge(where=(cluster=2));*/
/*	series x=t y=x1 / group=run lineattrs=(color=red);*/
/*run;*/
/**/
/*proc sgplot data=merge(where=(cluster=3));*/
/*	series x=t y=x1 / group=run lineattrs=(color=green);*/
/*run;*/
/**/
/*proc sgplot data=merge(where=(cluster=4));*/
/*	series x=t y=x1 / group=run lineattrs=(color=pink);*/
/*run;*/





proc transpose data=PAA out=PAA_transp(rename=(_name_=PAA_run)) prefix=s;
	var PAA:;
run;


%macro wrapper();
	data SAX_runs(keep=run SAX_series);
		length run 8. SAX_series $ &SAX_units;
		set PAA_transp;
		run=scan(PAA_run,3,'_');
		%do i=1 %to &SAX_units;
			s_&i=put(put(s&i,2.),$SAX.);
		%end;
		SAX_series=cats(of s_1-s_&SAX_units);
	run;
%mend;

%wrapper;


proc freq data=SAX_runs order=freq;
	tables SAX_series;
	output out=SAX_freq;
run;

proc sql;
	create table SAX_distance as
 		select 
			t1.run as run,
			t2.run as run2,
			t1.SAX_series as series1, 
			t2.SAX_series as series2,
/* 			compged(t1.SAX_series,t2.SAX_series,999) as gedscore*/
			complev(t1.SAX_series,t2.SAX_series,&SAX_units) as levscore
 	from SAX_runs t1, SAX_runs t2
/* 	where t1.run < t2.run*/
	order by run, run2;
quit; 

proc transpose data=SAX_distance out=SAX_distance_matrix prefix=run_;
	var levscore;
	by run;
	id run2;
run;


proc cluster data=SAX_distance_matrix outtree=tree method=ward noprint;
   id run;
run;

proc tree data=tree horizontal ncl=4 out=cluster;
run;

proc sort data=cluster;
	by cluster _name_;
run;

data cluster;
	length run 8.;
	set cluster;
	run=input(strip(_name_),8.);
run;


proc transpose data=WINADO.wide_std out=test prefix=x;
	var run:;
	by t;
run;

proc sort data=test;
	by _name_ t;
run;

data test;
	set test;
	run=input(substr(_name_,5),8.);
run;


proc sql;
	create table merge as
	select *
	from test t1
	left join cluster t2
	on t1.run=t2.run
	order by run, t;
quit;


proc sgplot data=merge(where=(cluster=1));
	series x=t y=x1 / group=run lineattrs=(color=blue);
run;

proc sgplot data=merge(where=(cluster=2));
	series x=t y=x1 / group=run lineattrs=(color=red);
run;

proc sgplot data=merge(where=(cluster=3));
	series x=t y=x1 / group=run lineattrs=(color=green);
run;

proc sgplot data=merge(where=(cluster=4));
	series x=t y=x1 / group=run lineattrs=(color=pink);
run;






%let warp_constraint=10;

/*DTW Distance*/
proc similarity data=wide_std outsum=simmatrix;
   target run: / measure=sqrdev
              compress=(localpct=&warp_constraint globalpct=&warp_constraint)
              expand=(localpct=&warp_constraint globalpct=&warp_constraint);
run;



proc cluster data=simmatrix(drop=_status_) outtree=tree method=ward noprint;
   id _input_;
run;

proc tree data=tree horizontal ncl=4 out=cluster;
run;

proc sort data=cluster;
	by cluster _name_;
run;

proc sql;
	create table merge as
	select *
	from test t1
	left join cluster t2
	on t1._name_=t2._name_
	order by _name_, t;
quit;


proc sgplot data=merge(where=(cluster=1));
	series x=t y=x1 / group=run lineattrs=(color=blue);
run;

proc sgplot data=merge(where=(cluster=2));
	series x=t y=x1 / group=run lineattrs=(color=red);
run;

proc sgplot data=merge(where=(cluster=3));
	series x=t y=x1 / group=run lineattrs=(color=green);
run;

proc sgplot data=merge(where=(cluster=4));
	series x=t y=x1 / group=run lineattrs=(color=pink);
run;



