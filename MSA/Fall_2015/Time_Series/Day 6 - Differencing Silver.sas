goptions reset=all;
ods listing gpath = "%sysfunc(pathname(work))";

 /* Source METAL STATISTICS            */

DATA SILVER;
 INPUT SILVER @@; DEL = SILVER-LAG(SILVER);
   TITLE 'MONTH END STOCKS OF SILVER';
   RETAIN DATE '01DEC75'D;
   DATE=INTNX('MONTH',DATE,1);
   FORMAT DATE MONYY.;
 OUTPUT; RETAIN; DEL4=DEL3; DEL3=DEL2; ** trick for lagging; 
   DEL2=DEL1; DEL1=DEL; LSILVER=SILVER;                 ;
   CARDS;
 846  827  799  768  719  652  580  546  500  493  530  548
 565  572  632  645  674  693  706  661  648  604  647  684
 700  723  741  734  708  728  737  729  678  651  627  582
 521  519  496  501  555  541  485  476  515  606  694  748
 761  794  836  845
  ;

** Model 1:  Fit AR(2) - use sample mean (center option) to estimate mu **; 
proc arima DATA=SILVER plots=forecast(forecast);
  i var=silver noprint;
  e p=2 ml;
  f lead=72 out=outs ID=DATE INTERVAL=MONTH NOOUTALL;
run; 

** Model 2:  Difference then AR(1); 
proc arima data=silver plots=forecast(forecast);
  i var=silver(1) noprint;
  e p=1 ml noconstant;
  f lead=72 out=outn ID=DATE INTERVAL=MONTH NOOUTALL;
run; 
** Which model is better ??? ; 

** Step 1: Figure out p **; 
PROC REG data=silver; MODEL DEL=LSILVER DEL1 DEL2 DEL3 DEL4;
   TEST DEL2=0, DEL3=0, DEL4=0;   title ' ';
  *( t test using incorrect t distribution  ); 
PROC REG data=silver; MODEL DEL=LSILVER DEL1;
run; 

** Step 2: Do the unit root test;
proc arima data=silver;
 i var = silver stationarity=(Dickey=(1)) outcov=acf; 
                     ** REG suggested 1 augmenting lagged difference  **; 
run; quit; 

** What is your decision: stationary (model 1) or not stationary (model 2)?  **; 
;


/*  next months of data ; 

                     822  820  826  826  821  871  858  866
 859  854  854  853  848  867  856  785  774  758  773  776
 769  783  771  814  780  729  662  606  615  579  800  907
 904 1064  972  914  899  909  921 1136 1293 1279 1298 1274
1238 1174 1168 1153 1136 1209 1205 1151 1150 1145 1149 1185
1215 1233 1066 1068 1042 1324 1393 1434 1440 1492 1537 1553
1432 1453 1482 1552 1479 1519 1502 1587 1568 1377 1449 1454
1502 1600 1573 1577 1561 1522 1521 1601 1564 1548 1558 1563
*                    */;

