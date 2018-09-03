/*Author: William Nadolski - william.nadolski@sas.com*/
/*Data Sourced from: http://timeseriesclassification.com/description.php?Dataset=Trace */
/*Corresponding Jupyter Notebook: https://github.com/nadolsw/SAS/blob/master/Trace/Trace_DTW_TS_Clustering_Demo.ipynb */

libname WINADO "C:\Users\winado\Desktop\Trace"; /*Define Libref*/
/*ods graphics / border=off;*/

/*This 4-class dataset is a subset of the Transient Classification Benchmark (trace project)*/
/*It is a synthetic dataset designed to simulate instrumentation failures in a nuclear power plant, created by Davide Roverso.*/

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

title "Trace Dataset: All Runs Plotted";
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



/*DTW Distance*/
%let warp_constraint=35;
proc similarity data=wide_std outsum=simmatrix /*plots=all*/;
   target run: / measure=sqrdev
              compress=(localpct=&warp_constraint globalpct=&warp_constraint)
              expand=(localpct=&warp_constraint globalpct=&warp_constraint);
run;


proc cluster data=simmatrix(drop=_status_) outtree=tree method=ward noprint;
   id _input_;
run;


%let num_clust=4;
proc tree data=tree ncl=&num_clust out=cluster;
run;


proc sort data=cluster;
	by cluster _name_;
run;



/*Merge together run values and cluster membership*/
proc sql;
	create table merge_raw as
		select *
		from long_raw t1
		left join cluster t2
		on t1._name_=t2._name_
		order by _name_, t;
quit;

proc sql;
	create table merge_std as
		select *
		from long_std t1
		left join cluster t2
		on t1._name_=t2._name_
		order by _name_, t;
quit;


/*title "All Runs Plotted by Resulting Cluster Membership (Normalized Values)";*/
/*proc sgpanel data=merge_std;*/
/*	panelby cluster;*/
/*	series x=t y=sensor / group=run transparency=0.75 grouplc=cluster;*/
/*	colaxis label="Time";*/
/*	rowaxis label="Sensor Value";*/
/*run;*/

title "All Runs Plotted by Resulting Cluster Membership (Raw Values)";
proc sgpanel data=merge_raw;
	panelby cluster;
	series x=t y=sensor / group=run transparency=0.75 grouplc=cluster;
	colaxis label="Time";
	rowaxis label="Sensor Value";
run;


proc sql;
	create table verify_results as
	select distinct 
		t1.run, 
		t1.cluster, 
		t2.label
	from merge_raw t1
	left join solution t2
	on t1.run=t2.run
	order by run;

	create table label_by_clust as
	select distinct
		cluster,
		count(distinct label) as distinct_labels,
		label
	from verify_results
	group by cluster
	order by cluster;
quit;


