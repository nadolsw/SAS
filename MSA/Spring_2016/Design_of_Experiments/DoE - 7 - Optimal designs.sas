**************DESIGN OF EXPERIMENT MACROS************;

/*Finding a reasonable design size*/

%MktRuns(2**19)


/*If interested in interaction*/

%MktRuns(2**19, interact=x1*x2)


/*Generating the design with 20 runs or treatments*/

%MktEx(2**19, N=20)

PROC PRINT data=work.design; 
RUN; 

/*MktEx macro with interactions between x1 and x2*/

%MktEx(2**19, interact=1|2, N=21)

PROC PRINT data=work.design;
RUN;


*****GENERATING OPTIMAL DESIGNS****;
/*OPTEX PROCEDURE*/

DATA work.candidate;
do MAILPC="Envelope", "Postcard";
 do CREATIVE="1st Class Customer", "Sign up Today";
  do INTRO=0, 2.99;
   do DURATION=9, 12;
	do GOTO=4.99, 7.99;
	 do FIXED="Variable", "Fixed";
	  do REWARDS="No Rewards", "Rewards";
	   do BONUS=0, 10000;
		do BTCHG=0, 2;
		 do PRODUCT="Platinum", "Titanium";
		 IF NOT((MAILPC="Postcard" and CREATIVE="1st Class Customer")
		OR (REWARDS="No Rewards" and BONUS=10000)) then OUTPUT;
		  end;
	     end;
	    end;
	   end;
	  end;
	 end;
    end;
   end;
  end;
 end;
RUN;QUIT;
PROC OPTEX data=work.candidate;
  CLASS MAILPC--PRODUCT;
  MODEL MAILPC--PRODUCT;
  GENERATE KEEP=10
  			METHOD=m_fedorov
			ITER=200
			n=12;
  EXAMINE DESIGN VARIANCE INFORMATION;
RUN; QUIT;

*/Using the MktEx Macro with Restrictions/*;
%macro res;
	bad=(x1=1 & x2=1) + (x3=1 & x4=1);
%mend res;

%mktex(2**10, n=12, restrictions=res, out=work.twelve, seed=8675309);

/*Assigning factor names and levels*/

DATA work.key;
  length mailPc creative rewards $18. bonus 8.;
  infile datalines delimiter=",";
  input mailPc $ creative $ intro
  		duration goto fixed $
  		rewards $ bonus btchg
  		product $;
  datalines;
Postcard,1st Class Customer,0,9,4.99,Variable,No Rewards,10000,0,Platinum
Envelope,Sign up Today,2.99,12,7.99,Fixed,Rewards,0,2,Titanium
;
RUN;  

%Mktlab(key=work.key, data=work.twelve)

PROC print data=work.final;
RUN;

*/Evaluate impact of departure from 100% efficient designs/*;
%mkteval(data=work.twelve)
