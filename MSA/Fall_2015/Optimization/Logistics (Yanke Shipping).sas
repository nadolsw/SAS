data shipping;
	input supplier $ inventory to_boston to_newark to_toronto;
		datalines;
			Chicago 2000 4000 2500 1500
			Detroit 1500 3000 1500 1000
			;
		run;

data demand;
	input destination $ demand;
		datalines;
			Boston 500
			Newark 1500
			Toronto 1000
			;
		run;

proc optmodel;


	

proc optmodel;
*DEFINE VARIABLES*;
	var chi2bos >=0;
	var chi2new >=0;
	var chi2tor >=0;

	var det2bos >=0;
	var det2new >=0;
	var det2tor >=0;
*OBJECTIVE FUNCTIONS*;
	min cost1 = 4000*chi2bos + 2500*chi2new + 1500*chi2tor + 3000*det2bos + 1500*det2new + 1000*det2tor;
	max cost2 = 4000*chi2bos + 2500*chi2new + 1500*chi2tor + 3000*det2bos + 1500*det2new + 1000*det2tor;
*CONSTRAINTS*;
	con bos_order: chi2bos + det2bos = 500;
	con new_order: chi2new + det2new = 1500;
	con tor_order: chi2tor + det2tor = 1000;

	con chi_tot: chi2bos + chi2new + chi2tor <= 2000;
	con det_tot: det2bos + det2new + det2tor <= 1500;
*SOLVE MIN*;
	solve objective  cost1;
	print chi2bos chi2new chi2tor det2bos det2new det2tor;
*SOLVE MAX*;
	solve objective cost2;
	print chi2bos chi2new chi2tor det2bos det2new det2tor;

run; quit;
