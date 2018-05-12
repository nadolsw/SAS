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

*SETS*;
set <str> PRODUCTS;
read data product_data
	into PRODUCTS=[product];
put PRODUCTS;

set <str> DEPARTMENTS;
read data department_data
	into DEPARTMENTS=[department];
put DEPARTMENTS;


*INPUTS*;
num hrs{PRODUCTS, DEPARTMENTS};
read data department_data
	into [product department] hrs=time;
put hrs[*]=;

num demand{PRODUCTS};
read data product_data
	into [product] demand;
put demand[*]=;

num price{PRODUCTS};
read data product_data
	into [product] price;
put price[*]=;

num maxTime{DEPARTMENTS};
read data department_data
	into [department] maxTime;
put price[*]=;

num cost{DEPARTMENTS};
read data department_data
	into [department] cost;
put cost[*]=;


*VARS*;
var ProdQuan{PRODUCTS} >= 0;

impvar ProdHrs{p in PRODUCTS, d in DEPARTMENTS} =
	ProdQuan[p]*hrs[p,d];
impvar ProdCost {p in PRODUCTS} =
	ProdQuan[p] * sum{d in DEPARTMENTS} (hrs[p,d]*cost[d]);
impvar ProdRev{p in PRODUCTS} =
	price[p] * ProdQuan[p];
impvar ProdProfit{p in PRODUCTS} =
	ProdRev[p] - ProdCost[p];

*OBJECTIVE FUNCTION*;
max TotalProfit =
	sum{p in PRODUCTS} (ProdProfit[p]);

*CONSTRAINTS*;
con department_time{d in DEPARTMENTS}:
	sum{p in PRODUCTS} (ProdHrs[p,d]) <= maxTime[d];

con Prod_demand{p in PRODUCTS}:
	ProdQuan[p] <= demand[p];

solve;

print ProdQuan;

create data solution from [PRODUCTS] ProdQuan;

quit;
