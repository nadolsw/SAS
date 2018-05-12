
/* PRIMAL */

proc optmodel;

/* Define vars */
var x1 >= 0;
var x2 >= 0;

/* Define Implicit Variables for Objective Function */
max profit = 102*x1 + 387*x2;

/* Define Constraints */
con assembly: 3*x1 + 5*x2 <= 240;
con shipping: 2*x1 + 3*x2 <= 160;
con chairs_demand: x1 <= 360;
con tables_demand: x2 <= 80;

/* Solve */
solve objective profit;

print x1 x2;
print assembly.dual shipping.dual chairs_demand.dual tables_demand.dual;

quit;


/* DUAL */

proc optmodel;

/* Define vars */
var y1 >= 0;
var y2 >= 0;
var y3 >= 0;
var y4 >= 0;

/* Define Implicit Variables for Objective Function */
min profit = 240*y1 + 160*y2 + 360*y3 + 80*y4;

/* Define Constraints */
con chairs_prod: 3*y1 + 2*y2 + y3 + y4 >= 102;
con tables_prod: 5*y1 + 3*y2 >= 387;


/* Solve */
solve objective profit;

print y1 y2 y3 y4;
print chairs_prod.dual tables_prod.dual;

quit;
