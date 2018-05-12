  /* --------------------------------------------------------------
  |  NCSU campuswide energy consumption 1979-80 school year.       |
  |  Indicators for workdays and class days.                       |
   ---------------------------------------------------------------*/
ods listing gpath="%sysfunc(pathname(work))";
goptions reset=all; 

PROC FORMAT; value daytype 0="non work" 1="work"  2="class"; 

DATA ENERGY;
  INPUT  DAY TEMP DEMAND T  WORK  CLASS  DATE :date7.  Y 67 ;
  TEMPSQ=(TEMP-65)**2;
  S=SIN(2*3.14159*date/365); C = COS(2*3.14159*DATE/365);
  FORMAT DATE DATE7.;   WC = WORK+CLASS; TITLE "NCSU energy demand";
  FORMAT WC DAYTYPE.;
FORMAT WC DAYTYPE.; 
*             10       20        30        40         50       60
123456789 123456789 123456789 123456789 123456789 123456789 123456789;
cards;
          1     83       8217    1      0       0      01JUL79    2
          2     87      12545    2      1       1      02JUL79    1
          3     85      12649    3      1       1      03JUL79    1
          4     85       9409    4      0       0      04JUL79    0
          5     80      12001    5      1       1      05JUL79    1
          6     78      11457    6      1       1      06JUL79    1
          7     75       8476    7      0       0      07JUL79    2
          8     82       8398    1      0       0      08JUL79    0
          9     82      12649    2      1       1      09JUL79    1
         10     79      12701    3      1       1      10JUL79    1
         11     84      12986    4      1       1      11JUL79    1
         12     89      13686    5      1       1      12JUL79    1
         13     88      13841    6      1       1      13JUL79    1
         14     88       9487    7      0       0      14JUL79    0
         15     87       9331    1      0       0      15JUL79    0
         16     89      13712    2      1       1      16JUL79    1
         17     89      13815    3      1       1      17JUL79    1
         18     77      13297    4      1       1      18JUL79    1
         19     81      13012    5      1       1      19JUL79    1
         20     81      12753    6      1       1      20JUL79    1
         21     82       9228    7      0       0      21JUL79    0
         22     83       8994    1      0       0      22JUL79    0
         23     80      13167    2      1       1      23JUL79    1
         24     82      13427    3      1       1      24JUL79    1
         25     85      13504    4      1       1      25JUL79    1
         26     82      13245    5      1       1      26JUL79    1
         27     86      13141    6      1       1      27JUL79    1
         28     87       9564    7      0       0      28JUL79    0
         29     88       9461    1      0       0      29JUL79    0
         30     79      13401    2      1       1      30JUL79    1
         31     89      13530    3      1       1      31JUL79    1
          1     90      14100    4      1       1      01AUG79    2
          2     90      14282    5      1       1      02AUG79    1
          3     86      13841    6      1       1      03AUG79    1
          4     87       9409    7      0       0      04AUG79    0
          5     89       9253    1      0       0      05AUG79    0
          6     90      13660    2      1       1      06AUG79    1
          7     90      13971    3      1       1      07AUG79    2
          8     94      13789    4      1       1      08AUG79    1
          9     93      13271    5      1       0      09AUG79    1
         10     95      13375    6      1       0      10AUG79    1
         11     90       9461    7      0       0      11AUG79    0
         12     74       7880    1      0       0      12AUG79    0
         13     79      11275    2      1       0      13AUG79    1
         14     84      11871    3      1       0      14AUG79    1
         15     82      11897    4      1       0      15AUG79    1
         16     77      11223    5      1       0      16AUG79    1
         17     79      11068    6      1       0      17AUG79    1
         18     84       8243    7      0       0      18AUG79    0
         19     90       8424    1      0       0      19AUG79    0
         20     89      13427    2      1       0      20AUG79    1
         21     89      13686    3      1       0      21AUG79    1
         22     80      12934    4      1       0      22AUG79    1
         23     83      14152    5      1       1      23AUG79    1
         24     85      13997    6      1       1      24AUG79    1
         25     87      10083    7      0       0      25AUG79    0
         26     88      10212    1      0       0      26AUG79    0
         27     84      15293    2      1       1      27AUG79    1
         28     96      15137    3      1       1      28AUG79    1
         29     85      15034    4      1       1      29AUG79    1
         30     90      14956    5      1       1      30AUG79    1
         31     87      14412    6      1       1      31AUG79    1
          1     84       9616    7      0       0      01SEP79    2
          2     84       9305    1      0       0      02SEP79    0
          3     88       9850    2      0       0      03SEP79    0
          4     80      14982    3      1       1      04SEP79    1
          5     74      14878    4      1       1      05SEP79    1
          6     88      15085    5      1       1      06SEP79    1
          7     85      14619    6      1       1      07SEP79    2
          8     79       9901    7      0       0      08SEP79    0
          9     75       9176    1      0       0      09SEP79    0
         10     79      13452    2      1       1      10SEP79    1
         11     81      13867    3      1       1      11SEP79    1
         12     81      14412    4      1       1      12SEP79    1
         13     81      14723    5      1       1      13SEP79    1
         14     85      15215    6      1       1      14SEP79    1
         15     75       9772    7      0       0      15SEP79    0
         16     75       9331    1      0       0      16SEP79    0
         17     80      13090    2      1       1      17SEP79    1
         18     82      13349    3      1       1      18SEP79    1
         19     85      13893    4      1       1      19SEP79    1
         20     74      13452    5      1       1      20SEP79    1
         21     78      14126    6      1       1      21SEP79    1
         22     85      10472    7      0       0      22SEP79    0
         23     66       9098    1      0       0      23SEP79    0
         24     62      12701    2      1       1      24SEP79    1
         25     62      12597    3      1       1      25SEP79    1
         26     70      12779    4      1       1      26SEP79    1
         27     76      13064    5      1       1      27SEP79    1
         28     79      13867    6      1       1      28SEP79    1
         29     73      10575    7      0       0      29SEP79    0
         30     73       9746    1      0       0      30SEP79    0
          1     80      14075    2      1       1      01OCT79    2
          2     80      14100    3      1       1      02OCT79    1
          3     73      13167    4      1       1      03OCT79    1
          4     76      13167    5      1       1      04OCT79    1
          5     66      12934    6      1       1      05OCT79    1
          6     69       8631    7      0       0      06OCT79    0
          7     70       8605    1      0       0      07OCT79    2
          8     71      12493    2      1       1      08OCT79    1
          9     80      13038    3      1       1      09OCT79    1
         10     64      12312    4      1       1      10OCT79    1
         11     54      11794    5      1       1      11OCT79    1
         12     75      12027    6      1       1      12OCT79    1
         13     67       8191    7      0       0      13OCT79    0
         14     59       7543    1      0       0      14OCT79    0
         15     67      10783    2      1       0      15OCT79    1
         16     75      11146    3      1       0      16OCT79    1
         17     78      12986    4      1       1      17OCT79    1
         18     80      13167    5      1       1      18OCT79    1
         19     80      12649    6      1       1      19OCT79    1
         20     81       9694    7      0       0      20OCT79    0
         21     82       9461    1      0       0      21OCT79    0
         22     80      14075    2      1       1      22OCT79    1
         23     77      13764    3      1       1      23OCT79    1
         24     63      12493    4      1       1      24OCT79    1
         25     60      12623    5      1       1      25OCT79    1
         26     59      12131    6      1       1      26OCT79    1
         27     58       8709    7      0       0      27OCT79    0
         28     74       8657    1      0       0      28OCT79    0
         29     72      13064    2      1       1      29OCT79    1
         30     72      12908    3      1       1      30OCT79    1
         31     69      12701    4      1       1      31OCT79    1
          1     73      12856    5      1       1      01NOV79    2
          2     72      13090    6      1       1      02NOV79    1
          3     61       8813    7      0       0      03NOV79    0
          4     56       8346    1      0       0      04NOV79    0
          5     57      11949    2      1       1      05NOV79    1
          6     61      11949    3      1       1      06NOV79    1
          7     60      11845    4      1       1      07NOV79    2
          8     60      11897    5      1       1      08NOV79    1
          9     70      11638    6      1       1      09NOV79    1
         10     75       8709    7      0       0      10NOV79    0
         11     63       8217    1      0       0      11NOV79    0
         12     47      11638    2      1       1      12NOV79    1
         13     50      11742    3      1       1      13NOV79    1
         14     48      11612    4      1       1      14NOV79    1
         15     51      11431    5      1       1      15NOV79    1
         16     58      11249    6      1       1      16NOV79    1
         17     65       7880    7      0       0      17NOV79    0
         18     72       8139    1      0       0      18NOV79    0
         19     71      12105    2      1       1      19NOV79    1
         20     74      11975    3      1       1      20NOV79    1
         21     72      11223    4      1       1      21NOV79    1
         22     71       6610    5      0       0      22NOV79    0
         23     74       7128    6      0       0      23NOV79    0
         24     75       7284    7      0       0      24NOV79    0
         25     72       7543    1      0       0      25NOV79    0
         26     69      12105    2      1       1      26NOV79    1
         27     66      11975    3      1       1      27NOV79    1
         28     62      11794    4      1       1      28NOV79    1
         29     42      11223    5      1       1      29NOV79    1
         30     40      11094    6      1       1      30NOV79    1
          1     49       7828    7      0       0      01DEC79    2
          2     39       7569    1      0       0      02DEC79    0
          3     37      11146    2      1       1      03DEC79    1
          4     54      11249    3      1       1      04DEC79    1
          5     59      11483    4      1       1      05DEC79    1
          6     51      11612    5      1       1      06DEC79    1
          7     54      11094    6      1       1      07DEC79    2
          8     53       7880    7      0       0      08DEC79    0
          9     45       7620    1      0       0      09DEC79    0
         10     60      11016    2      1       1      10DEC79    1
         11     65      10964    3      1       1      11DEC79    1
         12     70      11094    4      1       1      12DEC79    1
         13     69      11405    5      1       1      13DEC79    1
         14     58      10912    6      1       1      14DEC79    1
         15     48       7620    7      0       0      15DEC79    0
         16     57       7361    1      0       0      16DEC79    0
         17     44      10420    2      1       1      17DEC79    1
         18     44      10161    3      1       1      18DEC79    1
         19     57       9539    4      1       1      19DEC79    1
         20     40       9228    5      1       0      20DEC79    1
         21     41       8968    6      1       0      21DEC79    1
         22     50       5806    7      0       0      22DEC79    0
         23     58       5314    1      0       0      23DEC79    0
         24     69       5547    2      0       0      24DEC79    0
         25     53       5443    3      0       0      25DEC79    0
         26     55       5651    4      0       0      26DEC79    0
         27     56       5754    5      0       0      27DEC79    0
         28     55       5728    6      0       0      28DEC79    0
         29     58       5780    7      0       0      29DEC79    0
         30     54       5417    1      0       0      30DEC79    0
         31     53       8139    2      1       0      31DEC79    1
          1     44       5651    3      0       0      01JAN80    2
          2     52       5625    4      1       0      02JAN80    1
          3     48       9000    5      1       0      03JAN80    1   original data set had this one 0 (i.e. missing)
          4     39       9253    6      1       0      04JAN80    1
          5     38       6402    7      0       0      05JAN80    0
          6     43       6247    1      0       0      06JAN80    0
          7     48      10161    2      1       1      07JAN80    2
          8     47      10342    3      1       1      08JAN80    1
          9     41      10860    4      1       1      09JAN80    1
         10     43      10912    5      1       1      10JAN80    1
         11     62      11094    6      1       1      11JAN80    1
         12     52       7828    7      0       0      12JAN80    0
         13     38       7828    1      0       0      13JAN80    0
         14     48      11249    2      1       1      14JAN80    1
         15     62      11172    3      1       1      15JAN80    1
         16     55      11172    4      1       1      16JAN80    1
         17     49      11197    5      1       1      17JAN80    1
         18     50      11223    6      1       1      18JAN80    1
         19     59       7776    7      0       0      19JAN80    0
         20     58       7620    1      0       0      20JAN80    0
         21     54      11249    2      1       1      21JAN80    1
         22     54      10809    3      1       1      22JAN80    1
         23     54      10498    4      1       1      23JAN80    1
         24     50      10498    5      1       1      24JAN80    1
         25     60      10886    6      1       1      25JAN80    1
         26     51       7517    7      0       0      26JAN80    0
         27     42       7517    1      0       0      27JAN80    0
         28     52      11405    2      1       1      28JAN80    1
         29     45      11457    3      1       1      29JAN80    1
         30     40      11301    4      1       1      30JAN80    1
         31     30      10731    5      1       1      31JAN80    1
          1     28      10653    6      1       1      01FEB80    2
          2     31       7517    7      0       0      02FEB80    0
          3     32       7284    1      0       0      03FEB80    0
          4     31      10783    2      1       1      04FEB80    1
          5     38      11120    3      1       1      05FEB80    1
          6     32      10653    4      1       1      06FEB80    1
          7     39      11146    5      1       1      07FEB80    2
          8     42      10783    6      1       1      08FEB80    1
          9     33       7620    7      0       0      09FEB80    0
         10     36       7387    1      0       0      10FEB80    0
         11     44      11068    2      1       1      11FEB80    1
         12     41      11146    3      1       1      12FEB80    1
         13     45      11172    4      1       1      13FEB80    1
         14     56      11172    5      1       1      14FEB80    1
         15     61      10886    6      1       1      15FEB80    1
         16     52       8035    7      0       0      16FEB80    0
         17     35       7543    1      0       0      17FEB80    0
         18     44      11249    2      1       1      18FEB80    1
         19     53      11094    3      1       1      19FEB80    1
         20     61      11094    4      1       1      20FEB80    1
         21     66      11275    5      1       1      21FEB80    1
         22     70      11042    6      1       1      22FEB80    1
         23     77       7983    7      0       0      23FEB80    0
         24     68       7595    1      0       0      24FEB80    0
         25     49      11508    2      1       1      25FEB80    1
         26     40      11301    3      1       1      26FEB80    1
         27     52      11094    4      1       1      27FEB80    1
         28     63      11120    5      1       1      28FEB80    1
         29     52      10783    6      1       1      29FEB80    1
          1     27       6428    7      0       0      01MAR80    2
          2     19       5495    1      0       0      02MAR80    0
          3     39       7413    2      1       0      03MAR80    1
          4     50       9383    3      1       0      04MAR80    1
          5     50       9876    4      1       0      05MAR80    1
          6     56       9616    5      1       0      06MAR80    1
          7     63       9746    6      1       0      07MAR80    2
          8     63       6895    7      0       0      08MAR80    0
          9     67       6947    1      0       0      09MAR80    0
         10     66      11431    2      1       1      10MAR80    1
         11     53      11146    3      1       1      11MAR80    1
         12     43      11197    4      1       1      12MAR80    1
         13     36      11275    5      1       1      13MAR80    1
         14     54      11094    6      1       1      14MAR80    1
         15     62       7724    7      0       0      15MAR80    0
         16     67       7595    1      0       0      16MAR80    0
         17     68      11845    2      1       1      17MAR80    1
         18     57      11483    3      1       1      18MAR80    1
         19     66      11275    4      1       1      19MAR80    1
         20     64      11353    5      1       1      20MAR80    1
         21     68      11586    6      1       1      21MAR80    1
         22     60       7932    7      0       0      22MAR80    0
         23     59       7802    1      0       0      23MAR80    0
         24     58      11638    2      1       1      24MAR80    1
         25     67      11379    3      1       1      25MAR80    1
         26     56      11223    4      1       1      26MAR80    1
         27     61      11094    5      1       1      27MAR80    1
         28     58      10964    6      1       1      28MAR80    1
         29     70       7828    7      0       0      29MAR80    0
         30     59       7569    1      0       0      30MAR80    0
         31     65      11690    2      1       1      31MAR80    1
          1     66      11223    3      1       1      01APR80    2
          2     76      11742    4      1       1      02APR80    1
          3     78      11508    5      1       1      03APR80    1
          4     83      11612    6      1       1      04APR80    1
          5     63       6895    7      0       0      05APR80    0
          6     70       6454    1      0       0      06APR80    0
          7     61       7335    2      0       0      07APR80    2
          8     72      11457    3      1       1      08APR80    1
          9     81      12338    4      1       1      09APR80    1
         10     76      11845    5      1       1      10APR80    1
         11     78      11508    6      1       1      11APR80    1
         12     79       8476    7      0       0      12APR80    0
         13     69       8528    1      0       0      13APR80    0
         14     75      12934    2      1       1      14APR80    1
         15     59      11820    3      1       1      15APR80    1
         16     66      11638    4      1       1      16APR80    1
         17     65      11431    5      1       1      17APR80    1
         18     76      11353    6      1       1      18APR80    1
         19     77       8113    7      0       0      19APR80    0
         20     78       8113    1      0       0      20APR80    0
         21     79      11845    2      1       1      21APR80    1
         22     81      12286    3      1       1      22APR80    1
         23     93      13375    4      1       1      23APR80    1
         24     91      13712    5      1       1      24APR80    1
         25     87      13504    6      1       1      25APR80    1
         26     75       9383    7      0       0      26APR80    0
         27     81       9020    1      0       0      27APR80    0
         28     68      11483    2      1       1      28APR80    1
         29     71      11534    3      1       1      29APR80    1
         30     66      11379    4      1       1      30APR80    1
          1     70      11327    5      1       1      01MAY80    2
          2     77      11612    6      1       1      02MAY80    1
          3     79       8605    7      0       0      03MAY80    0
          4     84       8113    1      0       0      04MAY80    0
          5     86      12156    2      1       1      05MAY80    1
          6     85      12079    3      1       1      06MAY80    1
          7     86      11845    4      1       1      07MAY80    2
          8     67      10627    5      1       0      08MAY80    1
          9     68      10109    6      1       0      09MAY80    1
         10     69       8787    7      0       0      10MAY80    0
         11     84       6791    1      0       0      11MAY80    0
         12     90      11457    2      1       0      12MAY80    1
         13     89      12234    3      1       0      13MAY80    1
         14     85      12079    4      1       0      14MAY80    1
         15     72      10809    5      1       0      15MAY80    1
         16     77      10549    6      1       0      16MAY80    1
         17     78       7258    7      0       0      17MAY80    0
         18     86       7491    1      0       0      18MAY80    0
         19     86      12260    2      1       0      19MAY80    1
         20     73      12208    3      1       1      20MAY80    1
         21     82      12156    4      1       1      21MAY80    1
         22     85      12493    5      1       1      22MAY80    1
         23     84      12675    6      1       1      23MAY80    1
         24     80       8605    7      0       0      24MAY80    0
         25     80       8165    1      0       0      25MAY80    0
         26     78      11379    2      1       1      26MAY80    1
         27     79      11534    3      1       1      27MAY80    1
         28     86      12338    4      1       1      28MAY80    1
         29     90      13141    5      1       1      29MAY80    1
         30     87      13193    6      1       1      30MAY80    1
         31     87       8994    7      0       0      31MAY80    0
          1     88       8735    1      0       0      01JUN80    2
          2     90      13556    2      1       1      02JUN80    1
          3     96      13764    3      1       1      03JUN80    1
          4     87      13556    4      1       1      04JUN80    1
          5     83      12675    5      1       1      05JUN80    1
          6     85      12131    6      1       1      06JUN80    1
          7     89       9253    7      0       0      07JUN80    2
          8     95       9383    1      0       0      08JUN80    0
          9     77      12079    2      1       1      09JUN80    1
         10     86      12493    3      1       1      10JUN80    1
         11     82      12519    4      1       1      11JUN80    1
         12     80      12208    5      1       1      12JUN80    1
         13     80      11742    6      1       1      13JUN80    1
         14     85       8631    7      0       0      14JUN80    0
         15     96       8631    1      0       0      15JUN80    0
         16     94      13971    2      1       1      16JUN80    1
         17     82      12442    3      1       1      17JUN80    1
         18     72      11975    4      1       1      18JUN80    1
         19     84      12468    5      1       1      19JUN80    1
         20     88      12753    6      1       1      20JUN80    1
         21     81       8580    7      0       0      21JUN80    0
         22     88       8605    1      0       0      22JUN80    0
         23     88      13478    2      1       1      23JUN80    1
         24     78      13064    3      1       1      24JUN80    1
         25     74      12908    4      1       1      25JUN80    1
         26     75      12545    5      1       0      26JUN80    1
         27     92      12856    6      1       0      27JUN80    1
         28     96       9098    7      0       0      28JUN80    0
         29     96       8942    1      0       0      29JUN80    0
         30     88      13789    2      1       1      30JUN80    1
;
*(1) Graph seasonal sinusoid effect *; 
PROC GLM data=energy; 
  CLASS WC; 
  MODEL demand = S C WC; 
  OUTPUT out=out1 predicted=P_OLS;
run; 
 
PROC SGPLOT data=OUt1;
  SCATTER Y=DEMAND X=DATE/group=WC; 
  SERIES  Y=P_OLS  X=DATE/group=WC lineattrs=(thickness=2); 
run;

*(2) Graph temperature effect *; 
PROC SORT data=energy; 
  BY temp; 
PROC GLM data=energy; 
  CLASS WC; 
  MODEL demand = temp|temp WC; 
  OUTPUT out=out2 predicted=P_OLS;
run; 
PROC SORT data=out2; 
  BY temp; 
PROC SGPLOT data=OUt2;
  SCATTER Y=DEMAND X=temp/group=WC; 
  SERIES Y=P_OLS X=temp/group=WC lineattrs=(thickness=2); 
run;
PROC SORT data=energy; by date; 
*(3) Fit multiple regression with AR(p) errors *; 
** day of week adds about .0021 to R**2  ***;
** residualm is residual from just X part **; 
PROC AUTOREG data=energy; 
  MODEL DEMAND = TEMP TEMPSQ CLASS WORK S C 
   /NLAG=15 BACKSTEP DWPROB;
   output out=out3 
   predicted = p predictedm=pm 
   residual=r residualm=rm; 
run; 

PROC SGPLOT data=out3;  
  NEEDLE Y=RM X=DATE/GROUP=WC BASELINE=0 LINEATTRS=(PATTERN=SOLID); 
  TITLE "Need better model?";
  TITLE2 "Big negative residual on Jan. 2"; 
run; 

** (4) Try an ARIMA model - find outliers **;  
PROC ARIMA data=energy; 
  IDENTIFY var=demand crosscor=(temp tempsq class work s c) noprint;
   ESTIMATE input = (temp tempsq class work s c) plot;  
   ESTIMATE input = (temp tempsq class work s c) p=(1)(7) q=(14) ml; 
   ** P=(1)(7) means (1-a1 B)(1 - a2 B**7) = 1 -a1 B - a2 B**7 + a1 a2 B**8   ;  
    FORECAST lead=0 out=outARIMA id=date  interval=day;
               * 0.05/365 = .0001369863 (Bonferroni) *; 
  OUTLIER type=additive alpha=.0001369863 id=date;  
run;
/********************************************************************
January 2, 1980 Wednesday: Hangover Day :-)  .

March 3,1980 Monday: (internet news article) 
On the afternoon and evening of March 2, 1980, North Carolina experienced 
a major winter storm with heavy snow across the entire state and near 
blizzard conditions in the eastern part of the state. Widespread snowfall 
totals of 12 to 18 inches were observed over Eastern North Carolina, with 
localized amounts ranging up to 22 inches at Morehead City and 25 inches 
at Elizabeth City, with unofficial reports of up to 30 inches at Emerald 
Isle and Cherry Point (Figure 1).  This was one of the great snowstorms 
in Eastern North Carolina history. What made this storm so remarkable was 
the combination of snow, high winds, and very cold temperatures.


May 10,1980  Saturday: Graduation Spring semester.
*********************************************************************/;

*(5) Plot residuals and outliers *; 
* outliers variable multiplies residual by 0 (or 1 if outlier) *; 
DATA NEXT; 
  MERGE outarima energy; by date; 
   hangover     = (date="02Jan1980"d); 
   storm        = (date="03Mar1980"d); 
   graduation   = (date="10May1980"d); 
   outliers = residual*(hangover+storm+graduation); 

PROC SGPLOT data=next; 
  NEEDLE X=date Y=residual/group=WC lineattrs=(pattern=solid thickness=1.5); 
  NEEDLE X=date Y=outliers/lineattrs=(thickness=3 color=blue) markers; 
  TITLE "ARIMA residuals (shocks)"; 
run; 

* Large negative residual Jan 2  (technically a work day) ;  
PROC PRINT data=next; 
  WHERE abs(residual)>1300;
  FORMAT date weekdate30.; 
  VAR date demand forecast residual outliers; 
run; 

PROC ARIMA data=next; 
  IDENTIFY var=demand 
       crosscor=(temp tempsq class work s c hangover graduation storm) noprint;  
  ESTIMATE input = (temp tempsq class work s c hangover graduation storm) 
                                                           p=1 q=(7,14) ml;                           
  FORECAST lead=0 out=outARIMA2 id=date  interval=day; 
run;
DATA NEXT2; 
  MERGE energy outARIMA2; 
  BY date;
PROC SGPLOT data=next2; 
  BAND x=date upper=852 lower=-852; 
  NEEDLE x=date y=residual/group=wc; 
  TITLE2 "Band:  852 = 2*sqrt(error variance)"; 
run; 

PROC PRINT data=next2; 
  WHERE abs(residual)>1000; 
  VAR demand forecast residual date work class; 
  FORMAT date weekdate.; 
run; 
  
goptions reset=all; title " "; footnote " "; 




