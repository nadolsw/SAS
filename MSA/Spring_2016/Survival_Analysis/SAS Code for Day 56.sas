/*-----------------------------*/
/*     Cox Regression Model    */
/*                             */
/*        Matthew Austin       */
/*       MSA Class of 2016     */
/*-----------------------------*/

libname survival "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Data";

/* Proportional Hazards Model */

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio;
run;


/* Automatic Selection Techniques */

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio / selection=score;
run;

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio / selection=forward;
run;

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio / selection=backward;
run;

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio / selection=stepwise;
run;


/* Time Varying Variables */

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio employed;
	array emp(*) emp1-emp52;
	employed = emp[week];
run;

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio employed;
	array emp(*) emp1-emp52;
	employed = emp[week-1];
run;


/* Non-proportional Hazards Model */

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio fintime;
	fintime = fin*week;
run;

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age race wexp mar paro prio fintime;
	fintime = fin*(week > 13);
run;


/* Residuals & Influential Observations */

proc phreg data=Survival.Recid;
	model week*arrest(0)=fin age prio;
	output out=outres xbeta=xb resmart=mart resdev=dev ressch=schfin schage schprio ld=ld dfbeta=dfbfin dfbage dfbprio; 
run;

data outres;
	set outres;
	id = _n_;
run;

proc sgplot data=outres;
	scatter x=xb y=mart / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=xb y=dev / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=week y=schage / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=week y=schfin / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=week y=schprio / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=week y=ld / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=week y=dfbfin / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=week y=dfbage / datalabel=id;
run;

proc sgplot data=outres;
	scatter x=week y=dfbprio / datalabel=id;
run;
