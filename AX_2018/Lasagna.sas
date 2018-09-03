
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

/*proc sgplot data=sensor_data;*/
/*	series x=t y=sensor;*/
/*run;*/
	

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



data las1;
	set merged;
	sensor=sensor+rannorm(12345)*3;
run;


/*proc sgplot data=merged1;*/
/*	series x=t y=sensor / group=date;*/
/*run;*/



data las2;
	set las1;
	if run >=60 and run <= 90 then do;
		color=3;
		if t >= 1 then sensor=90+ranuni(12345)*2;
	end;
	else if run >= 150 and run < 210 then do;
		color=1;
		sensor=75-0.05*t+rannorm(12345)*5;
	end;	
	else color=2;
run;




data las3;
	set las2;
	if run >= 250 and run <= 325 then do;
		sensor=sensor-0.25*(run-250);
	end;
	if sensor > 100 then sensor=100;
	if sensor < 0 then sensor=0;
	if sensor=0 then sensor=.1;
	label sensor="Sensor Measure";
run;



proc sql;
	create table lasagna as
	select *
	from las3 t1
	left join (select sensor as ideal, t as t2 from sensor_data) t2
	on t1.t=t2.t2
	order by run, t;
quit;

data lasagna;
	set lasagna;
	if run ne 1 then ideal=100;
	if run ne 1 then t2=1441;
run;


proc sort data=las3 out=las4;
	by descending date descending run t;
run;


data clrresp;
retain id "myid";
length min $ 5 max $ 5;
input min $ max $ color $ altcolor $;
datalines;
_min_ 1   blue blue
2    2   green green
3   _max_ red   red
;
run;


title "All Data Plotted";
proc sgplot data=lasagna rattrmap=clrresp ;
	series x=t y=sensor / transparency=0.85 group=date colorresponse=color rattrid=myid ;
	series x=t2 y=ideal / lineattrs=(thickness=3 pattern=dash color=black);
	xaxis label="Time (Seconds)";
	yaxis label="Sensor Measure";
	y2axis label="";
run;

ods graphics / ANTIALIASMAX=180200 ANTIALIAS=on SUBPIXEL=on discretemax=10000;
ods graphics / width=800px height=600px ;

title "Lasagna Plots";
proc sgplot data=las4;
   heatmap x=t y=date / 
		colorresponse=sensor 
		discretey
		colormodel=(lightgray yellow red)
	;
	yaxis label="Run Date" labelattrs=(size=10pt) fitpolicy=thin;
	xaxis label="Time (Seconds)" labelattrs=(size=10pt) fitpolicy=thin;
run;