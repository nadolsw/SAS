libname hosp "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Optimization\Data\Hospital";

proc optmodel;

*SETS*;
set PHYSICIANS=2..5;
set <str> TYPES={'1','2','B'};

*INPUTS*;
num tempPROFIT{TYPES};
read data hosp.procedures_profit into [TYPE] tempProfit=profit;
put profit[*];



*==============GIBBERSH BELOW=============================*;
