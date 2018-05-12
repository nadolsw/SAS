data product_data;
	input product $ price demand;
	datalines;
		chairs 160 360
		tables 480 80
		;
	run;

data department_data;
input product $ department $ hours maxtime wage;
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

*INPUT PARAMETERS*;
num price{PRODUCTS};
num demand{PRODUCTS};
read data product_data
	into [product] price demand;
put price[*]=;
put demand[*]=;

num maxtime{DEPARTMENTS};
num wage{DEPARTMENTS};
read data department_data
	into [department] maxtime wage;
put maxtime[*]=;
put wage[*]=;

num hours{PRODUCTS, DEPARTMENTS};
read data department_data
	into [product department] hours;
put hours[*]=;

*VARIABLES*;
var quantity{PRODUCTS};

impvar revenue{p in PRODUCTS} = price[p]*quantity[p];
impvar totalhours{p  in PRODUCTS, d in DEPARTMENTS} = quantity[p] * hours[p,d];
impvar cost{p in PRODUCTS} = quantity[p] * sum{d in DEPARTMENTS}(wage[d]*hours[p,d]);
impvar profit{p in PRODUCTS} = revenue[p] - cost[p];

*OBJECTIVE*;
max totalprofit = sum{p in PRODUCTS} profit[p];

con department_time{d in DEPARTMENTS}:
	sum{p in PRODUCTS} (totalhours[p,d]) <= maxtime[d];
con demand_constraint{p in PRODUCTS}:
	quantity[p] <= demand[p];
con positivity{p in PRODUCTS}:
	quantity[p] >= 0;

solve;
print quantity;
