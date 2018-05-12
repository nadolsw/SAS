proc means data=tmp1.accepted_customers n nmiss mean std min max;
run;

proc freq data=tmp1.accepted_customers nlevels;
run;

proc means data=tmp2.rejected_customers n nmiss mean std min max;
run;

proc freq data=tmp2.rejected_customers nlevels;
run;
