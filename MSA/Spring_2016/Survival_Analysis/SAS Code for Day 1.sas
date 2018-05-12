/*-----------------------------*/
/*       Survival Curves       */
/*                             */
/*        Matthew Austin       */
/*       MSA Class of 2016     */
/*-----------------------------*/

libname Survival "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Survival Analysis\Data";

/* Survival Curves */

proc lifetest data=Survival.Loyalty;
	time Tenure;
run;

proc lifetest data=Survival.Loyalty maxtime=48;
	time Tenure;
run;


/* Stratified Survival Curves */

proc lifetest data=Survival.Loyalty maxtime=48;
	time Tenure;
	strata Loyalty;
run;


/* Life-Table (Actuarial) Method */

proc lifetest data=Survival.Loyalty method=life;
	time Tenure;
	strata Loyalty;
run;

proc lifetest data=Survival.Loyalty method=life width=1;
	time Tenure;
	strata Loyalty;
run;
