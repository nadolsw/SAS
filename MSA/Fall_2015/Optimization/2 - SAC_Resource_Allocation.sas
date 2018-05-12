libname teach "C:\Users\Instructor\Desktop\SAC";

data teach.resource_master (drop = skill);
/*format skillGroup;*/
do resourceID=1 to 324;
seniority='junior';
skill=round(rand('UNIFORM',1,2),1.0);
if skill=1 then skillGroup='Technical';
if skill=2 then skillGroup='Analytic';
output;
end;
run;

data teach.project_master (drop=skill ind);
do projectCode=1to 216;
skill=round(rand('UNIFORM',1,2),1.0);
if skill=1 then skillGroup='Technical';
if skill=2 then skillGroup='Analytic';
expBillHrs=round(rand('UNIFORM',40,480),1.0);
ind=round(rand('UNIFORM',1,3),1.0);
if ind=1 then industry='R';
if ind=2 then industry='T';
if ind=3 then industry='F';
output;
end;
run;

data teach.preference_master (drop=ind);
do resourceID=1 to 324;
do ind=1 to 3;
if ind=1 then industry='R';
if ind=2 then industry='T';
if ind=3 then industry='F';
pref=round(rand('UNIFORM',1,3),1.0);
output;
end;
end;
run;


/* Create in class */

proc sql;
create table teach.preference_detail as
select 
	a.resourceID
	,b.projectCODE
	,a.pref
from 
	teach.preference_master as a
	,teach.project_master as b
where 
	a.industry=b.industry;
quit;

proc sql;
create table teach.skill_detail as
select
	a.resourceID
	,b.projectCode
	,case
		when a.skillGroup=b.Skillgroup then 1
		else 0
		end
		as skill
		
from 	
	teach.resource_master as a
	,teach.project_master as b;
quit;
	 

proc optmodel;

set  PROJECTS;
read data teach.project_master into PROJECTS=[projectCode];

set  RESOURCES;
read data teach.resource_master into RESOURCES=[resourceID];

set  SENIORS;
read data teach.resource_master (where=(seniority='senior')) into SENIORS=[resourceID];
put SENIORS;


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



