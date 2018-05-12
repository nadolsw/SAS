 ods listing gpath = "%sysfunc(pathname(work))";
data a; 
  date = "01jan2000"d;
  do t=1 to 16;  Y=500 + round(80*normal(123)); 
  gap = round(20*ranuni(123))+1;
  date=intnx("day",date,gap); 
  output; end; 
proc print data=a; format date date9.; run; 
proc expand data=a from=day to=day 
out=out1 outest=spline; id date; 
convert Y = Ynew; 
data both; merge spline out1; by date; 
if (constant=.) and (date<"09jun2000"d) then Y=.; 
proc print data=both;  run; 
proc sgplot; 
scatter Y=Y X=date/markerattrs=(size=10); 
needle Y=Ynew X=date/ baseline=500; 
refline 500/axis=y;
Title "Misuse of PROC EXPAND"; 
run; 

