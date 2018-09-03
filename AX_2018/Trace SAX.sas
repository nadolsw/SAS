/*Author: William Nadolski - william.nadolski@sas.com*/
/*Data Sourced from: http://timeseriesclassification.com/description.php?Dataset=Trace */
/*Corresponding Jupyter Notebook: https://github.com/nadolsw/SAS/blob/master/Trace/Trace_PAA_%26_SAX_TS_Clustering_Demo.ipynb */

libname WINADO "C:\Users\winado\Desktop\Trace"; /*Define Libref*/

data trace;
	set WINADO.TRACE;
	run+1;
run;

proc sort data=trace;
	by label;
run;

data solution;
	set trace;
    keep label run;
run;


/*Convert to long data for graphing*/
proc transpose data=trace(drop=label) out=long(drop=_name_ rename=(COL1=sensor));
	var F: ;
	by run;
run;

data long;
	set long;
	by run;
	if first.run then t=0;
	t+1;
run;

title "All Runs Plotted";
proc sgplot data=long;
	series x=t y=sensor / group=run transparency=0.6;
	xaxis label="Time"; yaxis label="Sensor Value";
run;




/*Get all runs, one column per run on common time index t*/
proc transpose data=trace out=transp(drop=_name_) prefix=run_;
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


data WINADO.WIDE; set wide; run;
data WINADO.WIDE_STD; set wide_std; run;


title "Plot One Run for Each Label (Raw Values)";
proc sgplot data=wide;
	series x=t y=run_25;
	series x=t y=run_75;
	series x=t y=run_125;
	series x=t y=run_175;
	xaxis label="Time";
	yaxis label="Sensor Value";
run;
title;

title "Plot One Run for Each Label (Normalized Values)";
proc sgplot data=wide_std;
	series x=t y=run_25;
	series x=t y=run_75;
	series x=t y=run_125;
	series x=t y=run_175;
	xaxis label="Time";
	yaxis label="Sensor Value";
run;
title;


/*Convert wide to long for later merging with cluster membership*/
proc transpose data=wide out=long_raw;
	var run:;
	by t;
run;

proc sort data=long_raw;
	by _name_ t;
run;

data long_raw;
	set long_raw;
	rename COL1=sensor;
	run=input(substr(_name_,5),8.);
run;


proc transpose data=wide_std out=long_std;
	var run:;
	by t;
run;

proc sort data=long_std;
	by _name_ t;
run;

data long_std;
	set long_std;
	rename COL1=sensor;
	run=input(substr(_name_,5),8.);
run;



/*Converting each signal from lenth t to length &SAX_units*/
/*Converting each signal from min(sensor) to 0 and from max(sensor) to &SAX_symbols*/
%let SAX_units=11; /*Number of SAX time increments used to cover length of time t - needs to be a factor of 275*/
%let SAX_symbols=6; /*Number of SAX symbols to use - basically the max 'height' of the SAX representation - &SAX_symbols-1 needs to be a factor of 10*/
/*Apply SAX - resulting in 25 discrete time units (instead of 275)*/

proc sql noprint;
	select count(t) into: t_duration from wide_std;
quit;

%let SAX_unit_length=%sysevalf(&t_duration/&SAX_units); /*Number of time units in each SAX unit*/
%put &=SAX_unit_length;

/*Create mapping table from numeric value to SAX symbol*/
data SAX_lookup(drop=char_rank);
  input symbol $1. num 8.;
  num=0;
  output; 

  do num=1 to (&SAX_symbols-1);
  	char_rank=rank(symbol)+1;
    symbol=byte(char_rank);
    output;
  end;
  datalines;
a
run;


/*SAX format mapping for use after Piecewise Aggregate Approximation applied*/
data SAX2;
set SAX_lookup;
num=num/10;
run;

title "SAX Numeric to Character Mapping";
proc print noobs data=SAX2;
run;

/*Create SAX format*/
data SAX_format;
	set SAX_lookup;
	retain fmtname '$SAX' type 'C';
	start=put(num,2.);
	label=symbol;
	keep fmtname start label type;
run;

/*Load SAX format for later use*/
proc format cntlin=SAX_format;
run;

/*Time index mapping - reducing from max(t)=275 to max(s)=11*/
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

/*Will need to not be hard coded at some point*/
%if &SAX_units=11 and &SAX_symbols=11 %then %let multiplier=10;
%if &SAX_units=11 and &SAX_symbols=6 %then %let multiplier=5;
%if &SAX_units=5 and &SAX_symbols=6 %then %let multiplier=10;

proc sql;
	create table PAA(drop=dummy) as
	select distinct
		s,
/*		t,*/
/*		*,*/
		%do i=1 %to %sysfunc(countw(&run_list));
			%let this_run=%sysfunc(scan(&run_list,&i));
				round(avg(&this_run),0.1)*&multiplier as PAA_&this_run,
		%end;
		(1) as dummy
	from PAA
	group by s
	order by s;
quit;
%mend apply_PAA;

%apply_PAA;








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
 			compged(t1.SAX_series,t2.SAX_series,999) as gedscore
/*			complev(t1.SAX_series,t2.SAX_series,&SAX_units) as levscore*/
 	from SAX_runs t1, SAX_runs t2
/* 	where t1.run < t2.run*/
	order by run, run2;
quit; 

proc transpose data=SAX_distance out=SAX_distance_matrix prefix=run_;
	var gedscore;
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


proc transpose data=wide_std out=transp(rename=(col1=sensor));
	var run:;
	by t;
run;

proc sort data=transp;
	by _name_ t;
run;

data transp;
	set transp;
	run=input(substr(_name_,5),8.);
run;


proc sql;
	create table clustered_runs as
	select *
	from transp t1
	left join cluster t2
	on t1.run=t2.run
	order by run, t;
quit;


/*proc sgplot data=clustered_runs(where=(cluster=1));*/
/*	series x=t y=sensor / group=run lineattrs=(color=blue);*/
/*run;*/
/*proc sgplot data=clustered_runs(where=(cluster=2));*/
/*	series x=t y=sensor / group=run lineattrs=(color=red);*/
/*run;*/
/*proc sgplot data=clustered_runs(where=(cluster=3));*/
/*	series x=t y=sensor / group=run lineattrs=(color=green);*/
/*run;*/
/*proc sgplot data=clustered_runs(where=(cluster=4));*/
/*	series x=t y=sensor / group=run lineattrs=(color=pink);*/
/*run;*/


title "All Runs Plotted by Resulting Cluster Membership (Normalized Values)";
proc sgpanel data=clustered_runs;
	panelby cluster;
	series x=t y=sensor / group=run transparency=0.75 grouplc=cluster;
	colaxis label="Time";
	rowaxis label="Sensor Value";
run;







