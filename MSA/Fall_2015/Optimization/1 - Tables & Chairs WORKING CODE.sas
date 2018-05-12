data product_data;
input product $ price demand;
datalines;
	chairs 160 360
	tables 480 80
	;
run;

data department_data;
input product $ department $ time maxtime cost;
datalines;
	chairs assembly 3 240 12
	chairs shipping 2 160 11
	tables assembly 5 240 12
	tables shipping 3 160 11
	;
run;

proc optmodel;

/* Sets */

set <str> PRODUCTS;
read data product_data 
	into PRODUCTS=[product];
put PRODUCTS;

set <str> DEPARTMENTS;
read data department_data 
	into DEPARTMENTS=[department];
put DEPARTMENTS;

/* Parameters or Input */

num demand{PRODUCTS};
num price{PRODUCTS};
read data product_data
	into [product] demand price;
put demand[*]=;
put price[*]=;

num maxTime{DEPARTMENTS};
num cost{DEPARTMENTS};
read data department_data
	into [department] maxTime cost;
put maxTime[*]=;
put cost[*]=;

num hrs{PRODUCTS, DEPARTMENTS};
read data department_data
	into [product department] hrs=time;
put hrs[*]=;

/* Vars */

var ProdQuan{PRODUCTS} ;

impvar ProdRevenue{p in PRODUCTS}=
	price[p]*ProdQuan[p];

impvar ProdDeptHrs{p in PRODUCTS, d in DEPARTMENTS}=
	hrs[p,d]*ProdQuan[p];

impvar ProdCost{p in PRODUCTS} = 
	ProdQuan[p] * sum {d in DEPARTMENTS} ( cost[d]*hrs[p,d]);

impvar ProdProfit{p in PRODUCTS} =
	ProdRevenue[p] - ProdCost[p];

/* OF */

max TotalProfit = sum {p in PRODUCTS} ProdProfit[p];

/* Constraints */

con department_time{d in DEPARTMENTS}:
	sum {p in PRODUCTS} ( ProdDeptHrs[p,d] ) <= maxTime[d];

con product_demand{p in PRODUCTS}:
	ProdQuan[p] <= demand[p];

solve;

print ProdQuan;

create data solution from [PRODUCTS] ProdQuan ProdRevenue;

quit;


