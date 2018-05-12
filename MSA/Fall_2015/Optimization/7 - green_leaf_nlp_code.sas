libname gf "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Optimization\Data\NLP";

data gf.product_master;
set gf.product_master_clean;
beta=rand('UNIFORM', 8,12);
run;

proc optmodel;

/* Define Sets */
set SKUS;
read data gf.product_master into SKUS=[SKU];

/* Define Inputs */
num baseDemand{SKUS};
num beta{SKUS};
num listPrice{SKUS};
num cost{SKUS};

read data gf.product_master
	into [SKU] baseDemand=base_demand listPrice=list_price beta cost;

num upperBound{s in SKUS} = 1.2*listPrice[s];
num lowerBound{s in SKUS} = 0.8*listPrice[s];

/* Define Decision Variable */
var NewPrice{SKUS} >=0;

/* Define Implicit Variables */
impvar demand{s in SKUS}=baseDemand[s]*beta[s]/newprice[s];

impvar Profit{s in SKUS}=demand[s]*NewPrice[s] - demand[s]*cost[s];

/* Define Objective Function */
max TotalProfit = sum {s in SKUS} Profit[s];

/* Define Constraints */
con upper_bound{s in SKUS}: NewPrice[s]<= upperBound[s];

con lower_bound{s in SKUS}: NewPrice[s]>= lowerBound[s];

/* Solve */
solve;

/* Create Output Data */
create data gf.solution from [SKUS] listPrice NewPrice Profit demand basedemand cost;

quit;
