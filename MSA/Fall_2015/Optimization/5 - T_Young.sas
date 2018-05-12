libname tyoung "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Optimization\Data\T Young";

proc optmodel;

set TYPE;
read data tyoung.availability into TYPE=[emp_type];
put TYPE;

set  AVAILABILITY;
read data tyoung.availability into AVAILABILITY=[hrs];
put AVAILABILITY;

set  JOB;
read data tyoung.projects into JOB=[project];
put JOB;

set DURATION;
read data tyoung.projects into DURATION=[duration];
put DURATION;

set  PRICES;
read data tyoung.prices into =PRICES[emp_rate];
put PRICES;


var Assign{RESOURCES,PROJECTS} BINARY;

num pref{RESOURCES,PROJECTS};
read data teach.preference_detail
	into [resourceID projectCode] 
	pref;

num skill{RESOURCES,PROJECTS};
read data teach.skill_detail
	into [resourceID projectCode] 
	skill;

max Preference = sum {r in RESOURCES, p in PROJECTS}
				pref[r,p]*Assign[r,p];

con skills{p in PROJECTS}: 
	sum{r in RESOURCES} skill[r,p]*Assign[r,p]=1;

con resource{r in RESOURCES}:
	sum{p in PROJECTS} Assign[r,p] <= 1;

con project{p in PROJECTS}:
	sum{r in RESOURCES} Assign[r,p] = 1;

con must_assign{r in SENIORS}:
	sum{p in PROJECTS} Assign[r,p]=1;

solve;

create data teach.solution from [RESOURCES PROJECTS] Assign;

quit;

data teach.summary_solution (drop=assign);
set teach.solution;
if assign=1;
run;



