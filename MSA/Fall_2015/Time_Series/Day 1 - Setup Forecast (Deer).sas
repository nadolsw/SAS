/*--------------------------------------------------
|  Personal communication from the NC Dept. of       |
| Transportation.  Accident reports split into those |
| that mentioned deer and others.                    |
*---------------------------------------------------*/
***SETS OUTPUT PATH TO TEMPORARY FOLDER***;
 ods listing gpath="%sysfunc(pathname(work))";
 goptions reset=all; 
 proc datasets; delete out1 out2 out3; 

DATA DEER; 
  INPUT DATE DATE. DEER NONDEER;
  FORMAT DATE MONYY.;
  LABEL DEER = "NC accidents involving deer";
  LABEL NONDEER = "other reported accidents";
***CREATE LOGICAL/BOOLEAN DUMMY VARIABELS FOR EACH MONTH***;
	MONTH=MONTH(DATE); 
     X1=(MONTH=1);   X2=(MONTH=2);   X3=(MONTH=3); 
     X4=(MONTH=4);   X5=(MONTH=5);   X6=(MONTH=6); 
     X7=(MONTH=7);   X8=(MONTH=8);   X9=(MONTH=9); 
     X10=(MONTH=10); X11=(MONTH=11); X12=(MONTH=12);  
cards;
01JAN03     1218   18030 
01FEB03      937   16132
01MAR03     1013   16098
01APR03      805   17419
01MAY03      762   19054
01JUN03      833   17308
01JUL03      662   17864
01AUG03      583   18858
01SEP03      744   17595
01OCT03     2154   19531
01NOV03     3619   17530
01DEC03     2098   18590
01JAN04     1322   18507
01FEB04     1118   17501
01MAR04      960   16669
01APR04      818   17063
01MAY04      707   17847
01JUN04      722   17310
01JUL04      683   17314
01AUG04      604   18443
01SEP04      708   18276
01OCT04     2154   18194
01NOV04     3566   18625
01DEC04     2147   19468
01JAN05     1377   17388
01FEB05     1133   15170
01MAR05     1118   17075
01APR05      849   17312
01MAY05      771   17716
01JUN05      864   17534
01JUL05      674   17380
01AUG05      595   17449
01SEP05      870   15433
01OCT05     2285   18213
01NOV05     3311   17443
01DEC05     2093   18063
01JAN06     1575   15499
01FEB06     1094   14120
01MAR06      966   15649
01APR06      789   16597
01MAY06      780   17033
01JUN06      920   17895
01JUL06      776   15777
01AUG06      654   17355
01SEP06      814   17306
01OCT06     2566   19396
01NOV06     4095   18543
01DEC06     2575   17533
01JAN07     1613   16470
01FEB07     1345   15442
01MAR07     1376   17760
01APR07      839   16777
01MAY07      880   17187
01JUN07     1030   17035
01JUL07      943   16007
01AUG07      867   16884
01SEP07     1112   16838
01OCT07     2444   19596
01NOV07     4207   17230
01DEC07     2621   17804
01JAN08       .       . 
01FEB08       .       . 
01MAR08       .       . 
01APR08       .       . 
01MAY08       .       . 
01JUN08       .       . 
01JUL08       .       . 
01AUG08       .       . 
01SEP08       .       . 
01OCT08       .       . 
01NOV08       .       . 
01DEC08       .       . 
01JAN09       .       . 
01FEB09       .       . 
01MAR09       .       . 
01APR09       .       . 
01MAY09       .       . 
01JUN09       .       . 
01JUL09       .       . 
01AUG09       .       . 
01SEP09       .       . 
01OCT09       .       . 
01NOV09       .       . 
01DEC09       .       . 
   ;
* (1) Print and plot the data; 
PROC PRINT data=deer; 
PROC SGPLOT data=deer; TITLE "Accidents involving deer"; 
  SERIES Y=deer X=date; 
run;
 
ods graphics off; 
* (2) Trend plus November dummy; 
PROC REG data=deer;  
   TITLE "Trend plus November"; 
   MODEL deer=date X11;
   OUTPUT out=out1 predicted=p residual=r; 
run;  

PROC SGPLOT data=out1; Title2 "Predictions";
   SCATTER x=date y=deer; 
   SERIES x=date y=p; run; 

PROC SGPLOT data=out1; Title2 "Residuals"; 
   SERIES x=date y=r/markers; run; 


* (3) Trend plus October November December dummies; 
PROC REG data=deer;  
   TITLE "Trend plus November"; 
   MODEL deer=date X10 X11 X12;
   OUTPUT out=out2 predicted=p residual=r; 
run;  

PROC SGPLOT data=out2; Title2 "Predictions";
   SCATTER x=date y=deer; 
   NEEDLE x=date y=p; run; 

PROC SGPLOT data=out2; Title2 "Residuals"; 
   SERIES x=date y=r/markers; run; 

* (4) Trend plus all dummies except April; 
PROC REG data=deer;  
   TITLE "Trend plus Seaonal - April baseline"; 
   MODEL deer=date X1 X2 X3 X5-X12;
   OUTPUT out=out2 predicted=p residual=r; 
run;  

PROC SGPLOT data=out2; Title2 "Predictions";
   SCATTER x=date y=deer; 
   NEEDLE x=date y=p; run; 

PROC SGPLOT data=out2; Title2 "Residuals"; 
   SERIES x=date y=r/markers; run; 

* (5) Trend plus all dummies except December; 
PROC REG data=deer;  
   TITLE "Trend plus Seaonal - December baseline"; 
   MODEL deer=date X1-X11;
   OUTPUT out=out2 predicted=p residual=r; 
run;  

PROC SGPLOT data=out2; Title2 "Predictions";
   SCATTER x=date y=deer; 
   NEEDLE x=date y=p; run; 

PROC SGPLOT data=out2; Title2 "Residuals"; 
   SERIES x=date y=r/markers; run; 


goptions reset=all; title " "; footnote " "; 



