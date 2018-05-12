** Demo1_01Plot.sas **; 

ods listing gpath = "%sysfunc(pathname(work))";
LIBNAME LWFETSP "C:\TimeSeriesData";

Data work.amr; set LWFETSP.amr; 
title1 color=black "Volume, AMR Stock";
proc sgplot data=work.amr;
   series x=Date y=Volume / markers ; 
run;

/*----  Same exact plot, different syntax  ----*/

proc sgplot data=work.amr;  
   scatter x=Date y=Volume; 
   series x=Date y=Volume; 
run;

/*----  Histogram  ----*/

proc sgplot data=work.amr; 
   histogram Volume;  
   density Volume /type=normal; 
run; 

/*----  Add smoothing with a penalized B-spline  ----*/

proc sgplot data=work.amr;  
   scatter x=Date y=Volume; 
   series x=Date y=Volume; 
   pbspline x=Date y=Volume / smooth=40; 
run;

/*----  Need mean for needle baseline  ----*/

proc sql;
  select mean(LogVolume) into :LVMean
  from work.amr;
quit;
 
title1 "Volume, log scale, AMR stock"; 
proc sgplot data=work.amr; 
   scatter x=Date y=LogVolume; 
   pbspline x=Date y=LogVolume / smooth=40 lineattrs=(color=red thickness=3); 
   needle x=Date y=LogVolume / baseline=&LVMean; 
run; 

proc sgplot data=work.amr; 
   histogram LogVolume;
   density LogVolume/type=normal;  
run; 


title1 ; footnote1 ;

/*--------------------------*/
/*----  End of program  ----*/
/*--------------------------*/

