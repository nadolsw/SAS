******************************************************************************************************
****Customer life time value modeling******
******************************************************************************************************;

libname web "C:\Users\William\Desktop\NCSU MSA\Spring 2016\Web Analytics\Data";

data trans;
	set web.trans;
run;


/*RFM Analysis of trans donation data*/;
PROC PRINT Data=work.trans (OBS=10);
RUN;
/*Produce a rollup table first with ID as a unique customer*/
/*If a person donated in Feb 22, 2002, more than 4 years prior to 
our time period end (Sept 1, 2006), their recency state=4*/

********COMPUTE RFM as of SEPT 1, 2006: r6 f6 m6***********;

Data rollup;
	SET trans;
	BY id;
	LENGTH r6 f6 m6 4;
	RETAIN r6 f6 m6;/*use the retain statement to roll up transaction files*/
	ARRAY x{*} f6 m6;
	IF first.id THEN DO;
		DO i=1 to DIM(x);
			x{i}=0;
		END;
	r6=9999;
END;

/*compute RFM for 2006*/
diff=("31AUG2006"d - giftdate)/365.25;
IF diff>=0 THEN DO;
IF diff<r6 THEN r6=diff;
f6=f6+1;
m6=sum(amt, m6);
END;

IF LAST.id THEN OUTPUT;
KEEP id r6 f6 m6;
RUN;

PROC PRINT Data = rollup (OBS=10);
RUN;



/*Distribution of cancelation time: ISP*/
/*PMF and survival function of cancelation time for the ISP having a retention rate of 80%*/

Data geo;
t=0; p=0; St=1; OUTPUT;
t=1; p=0.2; St=1-p; OUTPUT;
DO t=2 to 25;
	p=P*0.8;
	St=St-p;
	OUTPUT;
  END;
 RUN;

 PROC SGPLOT DATA=geo;
 	STEP X=t Y=p;
	XAXIS LABEL = "Cancellation Time (t)";
	YAXIS LABEL = "Probability P(T=t)";
RUN;

PROC SGPLOT DATA=geo;
	STEP X=t Y=St;
	XAXIS LABEL = "Cancellation Time (t)";
	YAXIS LABEL = "Survival Function S(t)";
RUN;

/*CLV*/
DATA clv;
   DO r=0.7 to 0.98 by 0.01;
	Et=1/(1-r);
	Eclv = 25*1.01/(1.01-r);
	OUTPUT;
   END;
   FORMAT clv DOLLAR8.2
	r PERCENT5.0 Et 5.2;
   LABEL 
   	Et="E(T): Est Cancellation Time"
	Eclv="E(CLV): Est Value";
RUN;

PROC PRINT DATA=clv NOOBS LABEL;
   VAR r Et Eclv;
   WHERE MOD(100*r,5)=0 OR r=0.98;
RUN;

PROC SGPLOT DATA=clv;
   SERIES X=r Y=Eclv;
   XAXIS LABEL = "Retention Rate (r)";
RUN;

/*Retention Rate: Educational Service Provider*/
DATA service1yr;
   INPUT bigT cancel count @@;
   LABEL bigT="Cancelation Time (T)"
   cancel = "Dummy 1=cancel, 0=censored";
DATALINES;
2 1 4	3 1 16	4 1 20	5 1 37	6 1 28	7 1 61	8 1 24	9 1 19
10 1 13	11 1 10	12 1 13	1 0 3	3 0 2	4 0 1	5 0 7	6 0 33
7 0 49	8 0 63	9 0 30	10 0 16	11 0 34	12 0 188
RUN;

PROC PRINT Data=Service1yr;
RUN;
PROC MEANS DATA=service1yr SUM MAXDEC=0;
   VAR cancel bigT;
   WEIGHT count;
   OUTPUT OUT=answer SUM=;
RUN;

	/*Compute the retention rate using PROC SQL*/
PROC SQL;
   SELECT
   	cancels LABEL="Number Cancels",
	flips LABEL ="Opportunities to Cancel", 
	Rhat LABEL ="Retention Rate (r)" FORMAT=6.4,
	1/(1-Rhat) AS ET LABEL= "E(T)" FORMAT=5.1, 
	1+LOG(0.5)/LOG(Rhat) AS median LABEL ="Median(T)" FORMAT=3.0
   FROM (SELECT SUM(cancel) AS cancels,
	  SUM(bigT) as flips,
	  1-SUM(cancel)/SUM(bigT) as Rhat
   	FROM answer); quit;

	
