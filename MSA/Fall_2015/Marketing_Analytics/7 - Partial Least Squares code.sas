libname pls "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Marketing Analytics\Data";

data pls.pollution;
	set pollution;
run;

proc corr data=pollution;
run;

title; 
proc pls data = pollution method = pls(algorithm=nipals) cv=one 
     cvtest(seed=608789001) plot=(vip xscores parmprofiles dmodxy);
   model mort = prec--humid;
run;

/* PART 1 */
%let inputs = 	
    GiftCnt36
	GiftCntAll
	GiftCntCard36
	GiftCntCardAll
	GiftAvgLast
	GiftAvg36
	GiftAvgAll
	GiftAvgCard36
	GiftTimeFirst
	PromCntCard36
	PromCntCardAll
	StatusCat96NK
	StatusCatStarAll
	DemGender
	DemHomeOwner;

data pls.pva1;
	set pva1;
set;

proc pls data = work.pva1 method = pls(algorithm=nipals) cv=testset(work.pva2)  
        missing=avg cvtest(seed=600646001) varss plots=vip;
   class statuscat96nk demgender demhomeowner;
   effect Qage = polynomial(DemAge/degree=2); 
   model targetd = &inputs Qage/solution;
run;

/* PART 2 */
/* Reduce variables based on VIP and percent variance explained by the factors)  */
%let inputs = 	
    GiftCnt36
	GiftCntAll
	GiftCntCard36
	GiftCntCardAll
	GiftAvgLast
	GiftAvg36
	GiftAvgAll
	GiftAvgCard36
	StatusCat96NK_S
	StatusCatStarAll;
data new1;
set work.pva1;
   StatusCat96NK_S=StatusCat96NK='S';
run;
data new2;
set work.pva2;
   StatusCat96NK_S=StatusCat96NK='S';
run;
proc pls data = new1 method = pls(algorithm=nipals) cv=testset(new2)  
        missing=avg cvtest(seed=918428001) plots=(corrload(trace=off) vip xscores dmodxy) varss;
   class statuscat96nk_s;
   model targetd = &inputs/solution;
run;


/* PART 3 */
/* create scoring data set */
data pva2tmp;
   set new2;
   rename targetd = TargetNoUse;
run;
data pva;
   set new1 pva2tmp;
run;

/* score */
proc pls data = pva method = pls(algorithm=nipals) nfac=2
        missing=avg noprint;
   class statuscat96nk_s;
   model targetd = &inputs;
   output out=tscores predicted=pred;
run;

data scores; 
   set tscores;
   where targetd = .;
run;
/* show 100 highest predicted donation amounts */
proc sort data=scores out=sortscore;
   by descending pred;
run;

proc print data=sortscore(obs=100);
   format pred dollar6.2;
   var id pred;
run;

