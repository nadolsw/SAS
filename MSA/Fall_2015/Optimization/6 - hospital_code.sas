libname hosp "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Optimization\Data\Hospital";


proc optmodel;

/* Sets */
set PHYSICIANS= 2..5;
put PHYSICIANS;
set <str> TYPES = {'1','2','B'};
put TYPES;


/* Inputs */
num tempProfit{TYPES};
read data hosp.procedures_profit into [Type] tempProfit=profit;

num phSalary{PHYSICIANS};
read data hosp.physicians_salary into [number] phSalary=salary;

num profit{t in TYPES, p in PHYSICIANS} = tempProfit[t] -  phSalary[p];
put profit[*];

num waitTime{TYPES,PHYSICIANS};
read data hosp.time into [type number] waitTime=time;

/* Variable */
var Select{TYPES,PHYSICIANS} BINARY;


/* Objective Functions */
max TotalProfit = sum {t in TYPES, p in PHYSICIANS} profit[t,p] * Select[t,p] ;

min TotalWaitTime = sum {t in TYPES, p in PHYSICIANS} waitTime[t,p] * Select[t,p] ;


/* Constraints */
con selection: sum{t in TYPES, p in PHYSICIANS} select[t,p]=1;

con non_negative_profit: TotalProfit >= 0;

con max_wait_time: TotalWaitTime <= 300;

con TotalWaitTime <= 119;

/* Solve */
/*solve objective TotalWaitTime;*/
solve objective TotalProfit;

/* Output */
print Select TotalWaitTime TotalProfit;

quit;

