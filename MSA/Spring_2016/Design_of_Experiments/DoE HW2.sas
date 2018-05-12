*1. A clinical dietician wants to compare two different diets, A and B for diabetic patients.
Preliminary trials show that diet A (group 1) will be better than diet B in terms of lower blood glucose.
She plans to get a random sample of diabetic patients and randomly assign them to one of the two diets.
The experiment will last 6 weeks at the end of which, the fasting blood glucose level for each patient will be tested.
She expects that the average difference in blood glucose measure between the two groups will be about 10mg/dl.
Preliminary findings also show that the standard deviation for the blood glucose distribution for diet A is 15 and the
standard deviation for diet B is about 17.

a. The dietician wants to know the number of subjects needed in each group
assuming equal sized groups. She sets the power level to 0.80.*;

proc power;
	twosamplemeans test=diff_satt
	meandiff=10	sides=1 groupstddevs=15|17
	alpha=0.05 power=0.8 ntotal=.;
run;

*b. Suppose that the dietician can only collect data on 60 patients (with 30
in each group). What will be the statistical power for an alpha level of 0.05?*;

proc power;
	twosamplemeans test=diff_satt
	meandiff=10	sides=1 groupstddevs=15|17
	alpha=0.05 power=. ntotal=60;
run;

*2. Dr. D, the Marketing Manager from SD Bank wants to test three features of a standard mailer for credit cards:
interest rate, sticker (presence/absence) and size of graphic with the price on it.
The offer letter always has price graphic but it can be small or large.
The consulting team (your team) is brought in to help conduct a power and sample size analysis test for the offer.
Your team finds that the sales team has an idea of the best guess response rates for the credit card offer.*;

data prob2;
	input rate sticker $ graphic $ response;
		datalines;
		4.99 NO SMALL .006
		4.99 NO LARGE .0075
		4.99 YES SMALL .008
		4.99 YES LARGE .01
		1.99 NO SMALL .0085
		1.99 YES SMALL .01
		1.99 NO LARGE .01
		1.99 YES LARGE .012
		;
RUN;

proc glmpower data=prob2;
	class rate sticker graphic;
	model response = rate|sticker|graphic;
	power power=0.8 alpha=0.05 ntotal=. stddev=%SYSFUNC(SQRT(0.01*0.99));
run;
