
/*Run after Trace SAX*/


data clustered_runs_machine1 clustered_runs_machine2 clustered_runs_machine3 clustered_runs_machine4;
	set clustered_runs;
	Machine=cluster;
	if cluster=3 then output clustered_runs_machine4;
	if cluster=4 then output clustered_runs_machine1 clustered_runs_machine2 clustered_runs_machine3;
run;

proc sgpanel data=clustered_runs_machine;
	panelby machine;
	series x=t y=sensor / group=run transparency=0.75 grouplc=machine;
	colaxis label="Time";
	rowaxis label="Sensor Value";
run;


data machine3;
	set clustered_runs;
	Machine=8;
	if cluster=3;
run;

data machine4;
	set clustered_runs;
	Machine=9;
	if cluster=4;
run;

data machine4b;
	set machine4;
	run=run-100;
	machine=7;
run;

data machine4c;
	set machine4;
	run=run-150;
	machine=6;
run;

data all_machines;
set machine3 machine4 machine4b machine4c;
run;

proc sort data=all_machines;
	by run t;
run;

proc sgpanel data=all_machines;
	panelby machine;
	series x=t y=sensor / group=run transparency=0.75 grouplc=machine;
	colaxis label="Time";
	rowaxis label="Sensor Value";
run;










data date4;
	set clustered_runs;
	if cluster=2;
	Date='Q4_2017';
run;

data date1;
	set clustered_runs;
	if cluster=1;
	Date='Q1_2017';
run;

data date2;
	set clustered_runs;
	if cluster=1;
	Date='Q2_2017';
run;

data date3;
	set clustered_runs;
	if cluster=1;
	Date='Q3_2017';
run;

data all_dates;
set date1 date2 date3 date4;
run;

proc sort data=all_dates;
	by date run t;
run;

proc sgpanel data=all_dates;
	panelby Date;
	series x=t y=sensor / group=run transparency=0.75 grouplc=Date;
	colaxis label="Time";
	rowaxis label="Sensor Value";
run;