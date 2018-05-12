*EXAMINE TREATMENTS FOR EXPERIMENT HAVING FOUR FACTORS AT THREE LEVELS AND ONE FACTOR AT TWO LEVELS*;
%MKTRUNS(3**4 2**1);
*N=18 IS 100% EFFICIENT WITH ZERO VIOLATIONS (AS IS N=36 AS WELL) - MUST BE ORTHOGONAL ARRAY REFERENCE DESIGN - FULL FACTORIAL IS N=162*;

*UNRESTRICTED DESIGN*;
%MKTEX(3**4 2**1, N=18, seed=12345)



*INCORPORATE SINGLE INTERACTION FOR PRICE & BRAND*;
%MKTRUNS(3**4 2**1, interact=x1*x2);
*N=54 SEEMS TO BE BEST*;

*CREATE RESTRICTION MACRO FOR $2.99 PRICE AND 64 OZ SIZE*;
%macro res;
	bad=(x1=1 & x2=1);
%mend res;

*CREATE OUTPUT DESIGN DATASET*;
%MKTEX(3**4 2**1, N=54, interact=x1*x3, restrictions=res, out=work.fiftyfour, seed=12345);

*ASSIGN FACTOR NAMES AND LEVELS*;
DATA key;
	LENGTH Scent $10.;
	INFILE datalines delimiter=",";
	INPUT Brand $ Size Price Scent $ Softener $;
	DATALINES;
Complete,64,2.99,Lemon, No
Smile,48,3.99,Fresh, Yes 
Wave,32,4.99,Unscented, " " 
;
RUN;

%MKTLAB(key=key, data=fiftyfour);

PROC print data=final; RUN;
*DESIGN IS NOT APPLYING THE RESTRICTION FOR SOME REASON?*;

*/Evaluate impact of departure from 100% efficient designs/*;
%MKTEVAL(data=fiftyfour);



*CREATE "BAD" DATASET FOR PROC OPTEX WITH RESTRICTIONS*;
DATA work.candidate;
do BRAND="Complete", "Smile", "Wave";
 do PRICE="2.99", "3.99", "4.99";
  do SCENT="Lemon", "Fresh", "Unscented";
   do SIZE=32,48,64;
	do SOFTENER="Yes", "No";
		 IF NOT(PRICE="2.99" and SIZE=64) then OUTPUT;
		  end;
	     end;
	    end;
	   end;
	  end;
RUN;QUIT;

PROC OPTEX data=work.candidate SEED=12345;
  CLASS BRAND--SOFTENER;
  MODEL BRAND--SOFTENER;
  GENERATE KEEP=10
  			METHOD=m_fedorov
			ITER=2000
			n=54;
  EXAMINE DESIGN VARIANCE INFORMATION;
RUN; QUIT;
*PROBLEM: DOESN'T INCORPORATE THE INTERACTION - NOT SURE HOW TO DO SO IN PROC OPTEX*;
