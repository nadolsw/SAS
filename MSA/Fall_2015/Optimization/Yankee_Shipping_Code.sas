data costs;
	input Warehouse $ Customer $ cost;
	datalines;
		Chicago Boston 4
		Chicago Newark 2.5
		Chicago Toronto 1.5
		Detroit Boston 3
		Detroit Newark 1.5
		Detroit Toronto 1
		;
run;

data demand;
	input Customer $ demand;
	datalines;
		Boston 500
		Newark 1500
		Toronto 1000
		;
run;

data supply;
	input Warehouse $ supply;
	datalines;
		Chicago 2000
		Detroit 1500
		;
run;

proc optmodel;

/* Define Sets */

set <str> CUSTOMERS;
read data demand into CUSTOMERS=[Customer];

set <str> WAREHOUSES;
read data supply into WAREHOUSES=[Warehouse];


/* Define Inputs */

num cost{WAREHOUSES,CUSTOMERS};
read data costs into [Warehouse Customer] cost;

num demand{CUSTOMERS};
read data demand into [Customer] demand;

num supply{WAREHOUSES};
read data supply into [Warehouse] supply;


/* State Vars */

var Volume{WAREHOUSES,CUSTOMERS} >=0;

/* Define OF */

min TotalCost = sum{w in WAREHOUSES, c in CUSTOMERS} cost[w,c] * Volume[w,c];

/* Constraints */

con satisfy_demand{c in CUSTOMERS}: sum{w in WAREHOUSES} Volume[w,c] >= demand[c];

con dont_exceed_supply{w in WAREHOUSES}: sum{c in CUSTOMERS} Volume[w,c] <= supply[w];


/* Solve */

solve;

/* Print results */

print Volume;

quit;
