libname ty "C:\Users\Instructor\Desktop\SAC";

data ty.prices;
	input Emp_Type $ Project Price;
	datalines;
		Partner 1 160
		Partner 2 120
		Partner 3 110
		Senior 1 120
		Senior 2 90
		Senior 3 70
		Junior 1 0
		Junior 2 50
		Junior 3 40
		;
run;

data ty.availability;
	input Emp_Type $ hrs;
	datalines;
		Partner 200
		Senior 400
		Junior 400
	;
run;

data ty.projects;
	input Project Duration;
	datalines;
		1 500
		2 300
		3 100
		;
run;


proc optmodel;

set PROJECTS;
read data ty.projects 
	into PROJECTS=[project];

set <str> EMPTYPE;
read data ty.availability 
	into EMPTYPE=[emp_type];

var pen >= 0;
var hrsAssign{EMPTYPE,PROJECTS} >=0 INTEGER;

num price{EMPTYPE,PROJECTS};
read data ty.prices into [emp_type project] price;

num maxtime{EMPTYPE};
read data ty.availability into [emp_type] maxtime=hrs;
put maxtime[*]=;

num duration{PROJECTS};
read data ty.projects into [project] duration;

min penality=pen;

con emp_availability{e in EMPTYPE}:
	sum {p in PROJECTS} hrsAssign[e,p] <= maxtime[e];

con proj_duration{p in PROJECTS}:
	sum {e in EMPTYPE} hrsAssign[e,p] = duration[p];

con partner:
	sum {p in PROJECTS} hrsAssign['Partner',p] >=40;

con senior:
	sum {p in PROJECTS} hrsAssign['Senior',p] >=120;

con junior:
	hrsAssign['Junior',1]=0;

con pen1:
	68000 - sum{e in EMPTYPE, p in PROJECTS} price[e,p]*hrsAssign[e,p] <= pen;

con pen2:
	sum{e in EMPTYPE, p in PROJECTS} price[e,p]*hrsAssign[e,p]-68000 <= pen;


solve;

print hrsAssign;

print pen;

quit;



