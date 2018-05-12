libname mktg 'C:\Users\Joshua\Google Drive\Spring HW';

/* i imported the excel dataset after adding a variable called itemcount which is the sum of 1s per receipt 
this is important because for market basket analysis we do not use the receipts with only 1 product purchased 
in the data step below i state where itemcount >1 for this purpose */

/* Importing the data set */
proc import datafile="C:\Users\Joshua\Google Drive\Spring HW\ReceiptsFinal.csv" dbms=dlm out=work.receipts replace;
	 delimiter=",";
	 getnames=yes;
run;

data part1 (keep=Receipt_ID Products);
	length products $20;
	set receipts;
	where itemcount >1;
if chocolate_cake=1 then products= 'Chocolate Cake'; output;
if lemon_cake=1 then products= 'Lemon Cake'; output;
if casino_cake = 1 then products= 'Casino Cake' ; output;
if opera_cake = 1 then products= 'Opera Cake' ; output;
if  strawberry_cake = 1 then products= 'Strawberry Cake' ; output;
if  truffle_cake = 1 then products= 'Truffle Cake' ; output;
if  chocolate_eclair = 1 then products= 'Chocolate Eclair' ; output;
if  coffee_eclair = 1 then products= 'Coffe Eclair' ; output;
if  vanilla_eclair = 1 then products= 'Vanilla Eclair'; output;
if  napoleon_cake = 1 then products= 'Napolean Cake'; output;
if almond_tart = 1 then products= 'Almond Tart'; output;
if  apple_pie = 1 then products= 'Apple Pie' ; output;
if  apple_tart = 1 then products= 'Apple Tart' ; output;
if apricot_tart = 1 then products= 'Apricot Tart' ; output;
 if  berry_tart = 1 then products= 'Berry Tart' ; output;
 if  blackberry_tart = 1 then products= 'Blackberry Tart' ; output;
if  blueberry_tart = 1 then products= 'Blueberry Tart' ; output;
 if  chocolate_tart = 1 then products= 'Chocolate Tart' ; output;
if cherry_tart = 1 then products= 'Cherry Tart' ; output;
if  lemon_tart = 1 then products= 'Lemon Tart' ; output;
if  pecan_tart = 1 then products= 'Pecan Tart' ; output;
if  ganache_cookie = 1 then products= 'Ganache Cookie' ; output;
if  gongolais_cookie = 1 then products= 'Gongolais Cookie' ; output;
if  raspberry_cookie = 1 then products= 'Raspberry Cookie' ; output;
if lemon_cookie = 1 then products= 'Lemon Cookie' ; output;
if  chocolate_meringue = 1 then products= 'Chocolate Meringue' ; output;
if  vanilla_meringue = 1 then products= 'Vanilla Meringue' ; output;
if marzipan_cookie = 1 then products= 'Marzipan Cookie' ; output;
if  tuile_cookie = 1 then products= 'Tuile Cookie' ; output;
if  walnut_cookie = 1 then products= 'Walnut Cookie' ; output;
if  almond_croissant = 1 then products= 'Almond Croissant' ; output;
if apple_croissant = 1 then products= 'Apple Croissant' ; output;
if  apricot_croissant = 1 then products= 'Apricot Croissant' ; output;
if  cheese_croissant = 1 then products= 'Cheese Croissant' ; output;
if chocolate_croissant = 1 then products= 'Chocolate Croissant' ; output;
if apricot_danish = 1 then products= 'Apricot Danish' ; output;
if  apple_danish = 1 then products= 'Apple Danish' ; output;
if  almond_twist = 1 then products= 'Almond Twist' ; output;
if  almond_bear_claw = 1 then products= 'Almond Bear Claw' ; output;
if blueberry_danish = 1 then products= 'Blueberry Danish'; output;
if lemon_lemonade = 1 then products= 'Lemon Lemondade'; output;
if raspberry_lemonade = 1 then products= 'Raspberry Lemonade' ; output;
if  orange_juice = 1 then products= 'Orange Juice' ; output;
if green_tea = 1 then products='Green Tea' ; output;
if bottled_water = 1 then products= 'Bottled Water' ; output;
if hot_coffee = 1 then products= 'Hot Coffee' ; output;
if  chocolate_coffee = 1 then products= 'Chocolate Coffee' ; output;
if vanilla_frappuccino = 1 then products= 'Vanilla Frappuccino' ; output;
if cherry_soda = 1 then products= 'Cherry Soda' ; output;
if  single_espresso = 1 then products= 'Single Espresso'; output;
run;

data part2;
	set part1;
	where products is not missing;
run;

proc sort data=part2 nodup out=mktg.finalreceipt;
	by receipt_id;
run;


/* Importing Menu and Prices */
proc import datafile="C:\Users\Joshua\Google Drive\Spring HW\Price.csv" dbms=dlm out=work.price replace;
	 delimiter=",";
	 getnames=yes;
	 guessrows=100;
run;

*Cleaning up my spelling errors ;
data price;
	set price;
	if product="Coffee Eclair" then product="Coffe Eclair";
	if product="Napoleon Cake" then product="Napolean Cake";
	if product="Lemon Lemonade" then product="Lemon Lemondade";
	rename Price_in__=Price Category_Food__Drink_=Category;
run;

* Importing the rules ;
proc import datafile="C:\Users\Joshua\Google Drive\Spring HW\MBA.csv" dbms=dlm out=work.MBA replace;
	 delimiter=",";
	 getnames=yes;
	 guessingrows=20000;
run;

* Importing item sales ;
proc import datafile="C:\Users\Joshua\Google Drive\Spring HW\ItemStats.csv" dbms=dlm out=work.Sales replace;
	delimiter=",";
	getnames=yes;
	guessingrows=20000;
run;

* Sorting by product names;
proc sort data=Sales;
	by Product;
run;
proc sort data=Price;
	by Product;
run;


data ItemRevenue;
	merge Sales (in=s)
		  Price (in=p);
	by Product;
	Revenue = Count*Price;
run;

* Calculating revenue for MBA rules;

proc sql;

	/* Intermediate Steps towards calculating the sum of all prices in each rule.
			Not efficient, but it works */
	create table RuleRevenue1 as
	select m.*, p.price as price1, p.category as category1
	from MBA as m
		left join price as p
	on m.item1=p.product;

	create table RuleRevenue2 as
	select m.*, p.price as price2, p.category as category2
	from RuleRevenue1 as m
		left join price as p
	on m.item2=p.product;

	create table RuleRevenue3 as
	select m.*, p.price as price3, p.category as category3
	from RuleRevenue2 as m
		left join price as p
	on m.item3=p.product;

	create table RuleRevenue4 as
	select m.*, p.price as price4, p.category as category4
	from RuleRevenue3 as m
		left join price as p
	on m.item4=p.product;

	/* Calculating the revenue in one transaction for the rule, and total revenue the rule generates */
	create table RuleRevenueFinal as
	select *, SUM(price1,price2,price3,price4) as Trans_Revenue,
			  calculated Trans_Revenue * TransactionCnt as Total_Rule_Revenue
	from RuleRevenue4;
quit; 


ods csv file="";
