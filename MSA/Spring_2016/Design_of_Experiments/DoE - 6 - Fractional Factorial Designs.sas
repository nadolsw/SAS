**********FRACTIONAL FACTORIAL DESIGN*********;

**************/*PROC FACTEX*/************;

PROC FACTEX;
 	FACTORS
		Intro Duration Goto Color Creative Postage Rewards Fixed AnnFee BtChg;
	MODEL estimate=(Intro Duration Goto Color Creative Postage 
			Rewards Fixed AnnFee BtChg) / minabs;
	SIZE design = 16;
	EXAMINE confounding design; 
RUN; 
QUIT;

/*Recoding  or labeling levels of factors*/

PROC FACTEX;
 FACTORS Intro Duration Goto Color Creative Postage Rewards Fixed AnnFee BtChg;
 MODEL estimate=(Intro Duration Goto Color Creative Postage 
		Rewards Fixed AnnFee BtChg) / minabs;
SIZE design = 16;
OUTPUT OUT=work.two10m6
	Intro		nvals = (0 2.99)
	Duration 	nvals = (9 12)
	Goto		nvals = (4.99 7.99)
	Color 		cvals = ("white" "blue")
	Creative   	cvals = ("champion" "challenger")
	Postage 	cvals = ("first class" "third class")
	Rewards 	cvals = ("yes" "no")
	Fixed 		cvals = ("fixed" "variable")
	AnnFee 		cvals = ("no" "yes")
	BtChg		nvals = (0 2);
RUN; 
QUIT;

PROC PRINT data=work.two10m6;
RUN; 
/*Including 2 Blocks*/
PROC FACTEX;
 	FACTORS
		Intro Duration Goto Color Creative Postage Rewards Fixed AnnFee BtChg;
	MODEL estimate=(Intro Duration Goto Color Creative Postage 
			Rewards Fixed AnnFee BtChg) / minabs;
	SIZE DESIGN=16;
	BLOCKS NBLOCKS =2;
	OUTPUT out=work.blocks
	BLOCKNAME= gender cvals =("male" "female");
RUN; 
QUIT;

PROC PRINT data=work.blocks;
RUN; 

**********/*DESIGN MACROS*/***********;


%mktex(2**10, N=16);

/*Look at the design: work.design*/
PROC PRINT data=work.design;
RUN; 

*/Factor and levels: labels/*;
DATA work.key;
	LENGTH Creative Postage $11.;
	INFILE datalines delimiter=",";
	INPUT Intro Duration Goto
			Color $	Creative $	Postage $
			Rewards $ Fixed $ AnnFee $
			BtChg;
	DATALINES;
0,9,.0499,White,Champion,First Class,Yes,Fixed,No,0
.0299,12,.0799,Blue,Challenger,Third Class,No,Variable,Yes,.02
;
RUN; 
%mktlab(data=work.design, key=work.key) 

PROC PRINT data=work.key;
RUN;

PROC PRINT data=work.final;
	FORMAT intro goto btchg percent8.2;
	Var Intro Duration Goto Color Creative Postage Rewards Fixed AnnFee BtChg;
RUN; 





