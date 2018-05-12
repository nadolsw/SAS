****discrete choice design for breakfast bars***;
title "Breakfast Bars";
%mktruns(4 2 4 2 4 2);

/*find an efficient linear design*/
%mktex(4 2 4 2 4 2, n=16, seed=17);

/*evaluate  linear design in the randomized dataset*/
%mkteval(data=randomized);

/*print out the linear design*/
title2 'examine design';
proc print data=randomized;
run;

/*convert linear design into choice design*/
/*create a key dataset that describes how factors
in the linear design will be used to make choice design*/

%mktkey(3 2)

title2 "create the choice design key";
data key;
    input brand $ 1-14 price $ count $;
datalines;
Healthy_Grain x1 x2
Chewy_Oats    x3 x4
Fruit_N_Grain x5 x6
None          .  .
;

title2 "Create choice design from linear design";
%mktroll(design=randomized, key=key, alt=brand, out=cereal_design);

title2 "Final choice design";
proc format;
   value price 1 = $2.89 2=$2.99 3=$3.09 4=$3.19 .=" ";
   value count 1="six bars" 2="eight bars" .=" ";
 run;
data work.cereal_design;
set cereal_design;
format price price. count count.;
run;
proc print data=work.cereal_design (obs=16);
by set;
id set;
run;

/*evaluate the choice design*/
title2 "evaluate design";
%choiceff(data=work.cereal_design, 
init=work.cereal_design(keep=set),
intiter=0, model=class(brand price count brand*price brand*count/zero=none)
/ cprefix=0 lprefix=0, nalts=4, nsets=16, beta=zero)

/*run the macro with zero="none" option*/
%choiceff(data=work.cereal_design, 
init=work.cereal_design(keep=set),
intiter=0, 
model=class(brand price count brand*count/ zero='none')
/ cprefix=0 lprefix=0, nalts=4, nsets=16, beta=zero)

/*run the macro with but drop the last zero parameter*/
%choiceff(data=work.cereal_design, 
init=work.cereal_design(keep=set),
intiter=0, drop=Healthy_GrainSix_Bars ,
model=class(brand price count brand*count/
zero='none')/ cprefix=0 lprefix=0, nalts=4, nsets=16, beta=zero);

