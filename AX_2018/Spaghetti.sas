
/*Create root signal*/
data dat;                    
   input sensor;  
   datalines;         
0
0
0
0
5
15
10
30
20
50
30
50
70
40
60
80
50
70
90
60
70
90
100
100
100
;    
run;

data dat;
	set dat;
	t+1;
run;

proc expand data=dat out=sensor_data from=hour to=minute;
	convert sensor;
run;

/*1,441 seconds per run*/
data sensor_data;
	set sensor_data;
	t+1;
	drop datetime;
	if t < 180 then sensor=0;
	if t > 1321 then sensor=100;
run;

proc sgplot data=sensor_data;
	series x=t y=sensor / lineattrs=(thickness=2 pattern=dash color=black);
	xaxis label="Time (Seconds)";
	yaxis label="Sensor Measure";
run;
	

%let num_runs=365;


data runs;
	format date date9.;
	do r=1 to &num_runs;
		run=r;
		date=today()-&num_runs + r;
		output;
	end;
	drop r;
run;

data runs;
	set runs;
	by run;
	if first.run then t=0;
	do k=1 to 1441;
		t+1;
		output;
	end;
	drop k;
run;


proc sql;
	create table merged as
	select *
	from runs t1
	left join sensor_data t2
	on t1.t=t2.t
	order by run, t;
quit;



data sp1;
	set merged;
	sensor=sensor+rannorm(12345)*3;
run;


/*proc sgplot data=merged1;*/
/*	series x=t y=sensor / group=date;*/
/*run;*/



data sp2;
	set sp1;
	if run >= 90 and run < 150 then do;
		sensor=85-0.05*t+rannorm(12345)*5;
	end;
	if run >=30 and run <= 60 then do;
		if t >= 1 then sensor=25+ranuni(12345)*2;
	end;	
/*	if run >=15 and run < 90 then do;*/
/*		if t >= 1 then sensor=50+ranuni(12345)*2;*/
/*	end;*/
run;


/*proc sgplot data=sp2;*/
/*	series x=t y=sensor / group=date;*/
/*run;*/


data sp3;
	set sp2;
	if run >= 250 and run <= 365 then do;
		sensor=sensor-0.25*(run-250);
	end;
	if sensor > 100 then sensor=100;
	if sensor < 0 then sensor=0;
	if sensor=0 then sensor=.1;
	Run_Date=date;
	format Run_Date date9.;
	label run_date="Run Date";
run;


/*proc sgplot data=merged3(where=(run >= 450 and run < 600));*/
/*	series x=t y=sensor / group=date;*/
/*run;*/

data sp4;
	set sp3;
	if mod(run,5)=0;
run;


/*proc expand data=sp3 out=sp5;*/
/*   id t;*/
/*   convert sensor = sensor2  / transout=(ewma 0.25);*/
/*   by run;*/
/*run;*/
/**/
/*proc sgplot data=sp5(where=(run<50)) ;*/
/*	series x=t y=sensor / group=run;*/
/*	series x=t y=sensor2 / group=run;*/
/*run;*/


proc sql;
	create table test as
	select *
	from sp4 t1
	left join (select sensor as ideal, t as t2 from sensor_data) t2
	on t1.t=t2.t2
	order by run, t;
quit;

data test;
	set test;
	if run ne 5 then ideal=100;
	if run ne 5 then t2=1441;
run;


ods graphics / reset;
ods graphics on;
ods graphics / ANTIALIASMAX=180200 ANTIALIAS=on SUBPIXEL=on;
/*ods graphics / width=1200px height=1400px discretemax=10000;*/
ods listing close;
ods listing gpath='C:\Users\winado\Desktop\Trace' image_dpi=300;

/*goptions device=SASPRTC;*/
/*ods png file='C:\Users\winado\Desktop\Trace\spaghetti.png' image_dpi=300;*/


proc sgplot data=sensor_data;
	series x=t y=sensor / lineattrs=(thickness=2 pattern=dash color=black);
	xaxis label="Time (Seconds)";
	yaxis label="Sensor Measure";
run;

/*END DATA CREATION*/
title "Spaghetti Plot";
proc sgplot data=test;
   series x=t y=sensor / 
		group=run 
		colorresponse=run_date 
		colormodel=(black lightyellow gold royalblue)
        transparency=0.75 
		lineattrs=(thickness=1 pattern=solid)
	;
	series x=t2 y=ideal / lineattrs=(thickness=2 pattern=dash color=black) legendlabel="Idealized Curve" name="Idealized Curve"; 
	xaxis label="Time (Seconds)";
	yaxis label="Sensor Measure";
	y2axis label="Run Date";
	;
run;

ods pdf close;
/*ods listing;*/
