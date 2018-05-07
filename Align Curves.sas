
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


/*proc sgplot data=wide;*/
/*	series x=t y=run_25;*/
/*	series x=t y=run_75;*/
/*	series x=t y=run_125;*/
/*	series x=t y=run_175;*/
/*run;*/



/*Grab list of all run names*/
proc contents data=PAA out=cont(keep=name);
run;

%let base_run=PAA_run_1;
options mprint mlogic symbolgen;

proc sql noprint;
	select strip(name) into: run_list separated by " " from cont where name ne 's' and name ne "&base_run";
	select count(*) into: max_lag from PAA;
quit;

/*Delete any pre-existing xcorr_collector - only useful if program has previously been run in same session*/
proc delete data=xcorr_collector;


/*Use cross correlation function to identify optimal lag for alinging curves then shift each curve appropriately*/
%macro align_curves();
%do i=1 %to %sysfunc(countw(&run_list));
	%let this_run=%sysfunc(scan(&run_list,&i));

		proc timeseries data=PAA outcrosscorr=crosscorr;
		   id s interval=day;
		   crossvar &base_run &this_run;
		   crosscorr / nlag=&max_lag;
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

		%put LOOK: lag for &this_run is &lag;

		proc append base=xcorr_collector data=max_xcorr force;
		run;

		data &this_run;
			set PAA(keep=s &this_run);
			where &this_run is not missing;
			s=s+&lag;
		run;

		data PAA;
			merge &this_run PAA(drop=&this_run);
			by s;
		run;
	%end;
%mend align_curves;

%align_curves;



proc sgplot data=PAA;
/*	series x=s y=PAA_run_1;*/
/*	series x=s y=PAA_run_31;*/
	series x=s y=PAA_run_200;
	series x=s y=PAA_run_184;
run;


/*data WINADO.WIDE_STD;*/
/*	set wide_std;*/
/*run;*/


/*200 & 184*/



/*pad beg & end values*/
proc contents data=PAA out=cont(keep=name);
run;

proc sql noprint;
	select name into: name_list separated by " "
	from cont where name ne 's';
quit;

%macro wrapper();
	DATA PAA_filled ;
		SET PAA ;
		%do i=1 %to %sysfunc(countw(&name_list));
			%let this_run=%sysfunc(scan(&name_list,&i));
				retain X_&this_run;
				IF NOT MISSING(&this_run) THEN X_&this_run = &this_run ;
				&this_run = X_&this_run ;
		%end;
		drop X_: ;
	RUN ;

	proc sort data=PAA_filled;
		by descending s;
	run;

	DATA PAA_filled ;
		SET PAA_filled ;
		%do k=1 %to %sysfunc(countw(&name_list));
			%let this_run=%sysfunc(scan(&name_list,&k));
				retain X_&this_run;
				IF NOT MISSING(&this_run) THEN X_&this_run = &this_run ;
				&this_run = X_&this_run ;
		%end;
		drop X_: ;
	RUN ;

	proc sort data=PAA_filled;
		by s;
	run;
%mend;

%wrapper();



proc sgplot data=PAA_filled;
	series x=s y=PAA_run_25;
	series x=s y=PAA_run_75;
	series x=s y=PAA_run_125;
	series x=s y=PAA_run_175;
run;



proc transpose data=PAA_filled out=PAA_filled_transp(rename=(_name_=PAA_run)) prefix=s;
	var PAA:;
run;


%macro wrapper();
	data SAX_runs(keep=run SAX_series);
		length run 8. SAX_series $ &SAX_units;
		set PAA_filled_transp;
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

















ods graphics on;
/*DTW Distance*/
proc similarity data=wide_std plots=all outmeasure=measure outpath=path outsequence=sequence;
   target run_31 / measure=sqrdev
              	 compress=(localpct=25 globalpct=25)
              	 expand=(localpct=25 globalpct=25);
	input run_1;
run;


data path;
	set path;
	diff=_TARPTH_-_INPPTH_;
run;


proc sgplot data=DATA1008;
	series x=time y=run_1;
	series x=time y=run_31;
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
