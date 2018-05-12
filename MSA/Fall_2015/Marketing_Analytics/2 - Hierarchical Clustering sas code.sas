********************CLUSTERING METHODS:HIERARCHICAL CLUSTERING-LECTURE 2/3**********************;
/*Clustering using PROC CLUSTER*/


/*EXAMPLE 1a: CLUSTERING*/
/*Use the Pizza dataset*/;

LIBNAME VARRED "C:\Users\William\Desktop\NCSU MSA\Fall 2015\Marketing Analytics\Data";
DATA work.pizza;
	SET VARRED.pizza;
RUN;

%let inputs=carb mois sodium cal;

PROC DISTANCE Data=work.pizza METHOD=euclid out=distances;
	VAR interval(&inputs/std=range);
	COPY id brand;
RUN;

TITLE 'Pizza Nutrient Dataset';
TITLE2 'Average-Linkage Hierarchical Clustering';
PROC CLUSTER Data=distances METHOD=average OUTTREE=tree;
	VAR dist:;
	COPY id brand;
RUN;



*********EXTRA CODE TO GET ALL DIAGNOSTICS***********************************;
PROC DISTANCE Data=work.pizza METHOD=euclid out=distances2;
	VAR interval(&inputs/std=range);
	COPY id brand;
RUN;
PROC CLUSTER DATA=distances2 METHOD=ward ccc pseudo rmsstd rsq PRINT=20 outtree=tree2; 
	VAR dist:;
	COPY id brand ;
RUN;
******************************************************;



TITLE2 'TREE dataset (partial listing)';
PROC PRINT Data=tree (obs=10);
RUN;

/*Dendrogram of cluster solution is requested*/
TITLE2 'Dendrogram of the 9 Cluster Solution';
PROC TREE Data=tree level=0.25;
RUN;

/*Label each Observation with its Predicted Cluster Number*/

PROC TREE Data=tree NCLUSTERS=10 OUT=treeout NOPRINT;
	COPY id brand;
RUN;

TITLE2 'Treeout Dataset (Partial Listing)';
PROC PRINT Data=treeout (obs=10);
RUN;

/*Generate confusion matrix using PROC FREQ*/
TITLE2 'Confusion Matrix';
PROC FREQ Data=treeout;
	TABLES brand*cluster /norow nocol nopercent chisq OUT=freqout;
RUN;

/*PCA plots of the cluster solution generated*/

PROC PRINCOMP Data=work.pizza OUT=pcaout NOPRINT;
	VAR &inputs;
RUN;

TITLE 'PCA Plot of Pizza Brands';
PROC GPLOT Data=pcaout;
	PLOT Prin2*Prin1 =brand;
RUN;

PROC SORT Data=pcaout;
	BY id;
RUN;

PROC SORT Data=treeout;
	BY id;
RUN;

Data temp;
	MERGE pcaout treeout;
	BY id;
RUN;

TITLE 'PCA Plot of Derived Clusters';
PROC GPLOT Data=temp;
	PLOT Prin2*Prin1=cluster;
RUN;




***********************************************************************************
**********EXTRA CODE*********;
PROC DISTANCE Data=work.pizza METHOD=euclid out=distances;
	VAR interval(&inputs/std=range);
	COPY id brand &inputs;
RUN;

TITLE 'Pizza Nutrient Dataset';
TITLE2 'Average-Linkage Hierarchical Clustering';
PROC CLUSTER Data=distances METHOD=average OUTTREE=tree3;
	VAR dist:;
	COPY id brand &inputs;
RUN;

PROC TREE Data=tree3 NCLUSTERS=10 OUT=treeout1 NOPRINT;
	COPY id brand &inputs;
RUN;

PROC SORT DATA=treeout1;
BY CLUSTER;
RUN;
PROC MEANS DATA=treeout1 mean std;
	VAR &inputs;
	CLASS CLUSTER;
RUN;


*********BASED ON PSEUDO F and Dendrogram (4 CLUSTERS)**********;
PROC TREE Data=tree3 NCLUSTERS=4 OUT=treeout2 NOPRINT;
	COPY id brand &inputs;
RUN;

PROC SORT DATA=treeout2;
BY CLUSTER;
RUN;
PROC MEANS DATA=treeout2 mean std;
	VAR &inputs;
	CLASS CLUSTER;
RUN;
PROC FREQ Data=treeout2;
	TABLES brand*cluster /norow nocol nopercent chisq OUT=freqout2;
RUN;


********************************************************************************
***EXAMPLE 1b. CLUSTERING USING BINARY DATA***;
**DIVORCE DATASET**;

OPTIONS ls=120 ps=60;
DATA divorce;
   TITLE2 'Grounds for Divorce';
   INPUT State $15.
         (Incompatibility Cruelty Desertion Non_Support Alcohol
          Felony Impotence Insanity Separation) (1.) @@;
   IF mod(_n_,2) THEN input +4 @@; ELSE INPUT;
   DATALINES;
Alabama        111111111    Alaska         111011110
Arizona        100000000    Arkansas       011111111
California     100000010    Colorado       100000000
Connecticut    111111011    Delaware       100000001
Florida        100000010    Georgia        111011110
Hawaii         100000001    Idaho          111111011
Illinois       011011100    Indiana        100001110
Iowa           100000000    Kansas         111011110
Kentucky       100000000    Louisiana      000001001
Maine          111110110    Maryland       011001111
Massachusetts  111111101    Michigan       100000000
Minnesota      100000000    Mississippi    111011110
Missouri       100000000    Montana        100000000
Nebraska       100000000    Nevada         100000011
New Hampshire  111111100    New Jersey     011011011
New Mexico     111000000    New York       011001001
North Carolina 000000111    North Dakota   111111110
Ohio           111011101    Oklahoma       111111110
Oregon         100000000    Pennsylvania   011001110
Rhode Island   111111101    South Carolina 011010001
South Dakota   011111000    Tennessee      111111100
Texas          111001011    Utah           011111110
Vermont        011101011    Virginia       010001001
Washington     100000001    West Virginia  111011011
Wisconsin      100000001    Wyoming        100000011
;

PROC PRINT DATA=divorce (obs=10);
RUN;


TITLE 'Grounds for Divorce';
PROC DISTANCE DATA=divorce METHOD=djaccard ABSENT=0 OUT=distjacc;
    VAR anominal(Incompatibility--Separation);
    ID state;
RUN;

PROC PRINT DATA=distjacc(obs=10);
    ID state; 
    VAR alabama--georgia;
    TITLE2 'First 10 States';
RUN;

TITLE2;
PROC CLUSTER DATA=distjacc METHOD=centroid
	PSEUDO OUTTREE=tree;
	ID state;
	VAR alabama--wyoming;
RUN;

PROC TREE DATA=tree NOPRINT N=9 OUT=out;
	ID state;
RUN;

PROC SORT;
	BY state;
RUN;

DATA clus;
	MERGE divorce out;
	BY state;
RUN;

PROC SORT;
	BY cluster;
RUN;

PROC PRINT;
	ID state;
	VAR Incompatibility--Separation;
	BY cluster;
RUN;


********************************************************************************

/*EXAMPLE 2. CLUSTERING WITH DIFFERENT DISTANCE MEASURES*/
/*Stock Dataset*/

*/GENERATING DISTANCES/*;
data stock;
   title 'Stock Dividends';
   input Company &$26.  Div_1986 Div_1987 Div_1988 Div_1989 Div_1990;
   datalines;
Cincinnati G&E               8.4    8.2    8.4    8.1    8.0
Texas Utilities              7.9    8.9   10.4    8.9    8.3
Detroit Edison               9.7   10.7   11.4    7.8    6.5
Orange & Rockland Utilities  6.5    7.2    7.3    7.7    7.9
Kentucky Utilities           6.5    6.9    7.0    7.2    7.5
Kansas Power & Light         5.9    6.4    6.9    7.4    8.0
Union Electric               7.1    7.5    8.4    7.8    7.7
Dominion Resources           6.7    6.9    7.0    7.0    7.4
Allegheny Power              6.7    7.3    7.8    7.9    8.3
Minnesota Power & Light      5.6    6.1    7.2    7.0    7.5
Iowa-Ill Gas & Electric      7.1    7.5    8.5    7.8    8.0
Pennsylvania Power & Light   7.2    7.6    7.7    7.4    7.1
Oklahoma Gas & Electric      6.1    6.7    7.4    6.7    6.8
Wisconsin Energy             5.1    5.7    6.0    5.7    5.9
Green Mountain Power         7.1    7.4    7.8    7.8    8.3
;
**************Euclidean Distance*********
*/We use the range standardization for dividend vectors/*;
PROC DISTANCE data=work.stock METHOD=EUCLID OUT=Distances;
	ID Company;
	VAR interval(div_1986 div_1987 div_1988 div_1989 div_1990/STD=range);
RUN;

TITLE1 'Euclidean Distance Matrix';
PROC PRINT data=distances;
ID company;
RUN;

*If you have too many variables to compute the distances, you can rewrite the above*;
%let inputs=div_1986 div_1987 div_1988 div_1989 div_1990;

Title 'stock dividends';
Title2 'The STOCK dataset';
PROC PRINT DATA=work.stock;
	VAR Company &inputs;
RUN; 
PROC DISTANCE data=work.stock METHOD=EUCLID OUT=Distances;
	ID Company;
	VAR interval(&inputs/STD=range);
RUN;

TITLE1 'Euclidean Distance Matrix';
PROC PRINT data=distances;
ID company;
RUN;

*The distance matrix can be directly input into the CLUSTER procedure. We use 
Ward's hierarchical clustering method*;
*/We will output the clustering procedure to dataset=tree. We will then pass this 
on to the PROC TREE to see the dendrogram/*;

PROC CLUSTER DATA=distances METHOD=Ward OUTTREE=tree noprint;
ID Company;
RUN;
Title 'STOCK DIVIDENDS';
Title2 "cluster solution";
PROC TREE DATA=tree horizontal;
ID Company;
RUN;

********CITY BLOCK DISTANCE********
*/Less sensitive to outliers/*;

PROC DISTANCE DATA=work.stock METHOD=cityblock out=distances2;
	ID Company;
	VAR interval(&inputs/STD=range);
RUN;

Title2 "City Block Distances Matrix";
PROC PRINT DATA=Distances2;
	ID Company;
RUN;

PROC CLUSTER DATA=Distances2 METHOD=Ward OUTTREE=Tree2 noprint;
	ID Company;
RUN;
Title2 "Cluster Solution";
PROC TREE Data=Tree2 horizontal;
	ID Company;
RUN;


*********************************************************************************
/*Comparing Hierarchical Clustering Methods*/
/*Use the IRIS Dataset*/

/*Define a SCORECLUSTER macro*/
%macro scorecluster (dsn=, nc=, method=, k=, r=);
	title "&method";
	%if %upcase (&method)=EML %then %do;
		PROC CLUSTER Data=&dsn METHOD=EML OUTTREE=tree NOPRINT;
			VAR &inputs;
			COPY &inputs &group;
		RUN;
	%end;
	%else %do;
		PROC DISTANCE Data=&dsn METHOD=EUCLID OUT=temp;
			VAR interval(&inputs);
			COPY &inputs &group;
		RUN;
		%if &k NE %then %do; 	/*nearest neighbor*/

			PROC CLUSTER Data=temp METHOD=&method OUTTREE=tree k=&k NOPRINT;
				VAR dist:;
				COPY &inputs &group;
			RUN;
		%end;
		%else %if &r NE %then %do; /*radius*/
			PROC CLUSTER Data=temp METHOD=&method OUTTREE=tree R=&r NOPRINT;
				VAR dist:;
				COPY &inputs &group;
			RUN;
		%end;
		%else %do;
			PROC CLUSTER Data=temp METHOD=&method OUTTREE=tree NOPRINT;
				VAR dist:;
				COPY &inputs &group;
			RUN;
		%end;
	%end;
			PROC TREE Data=tree NCLUSTERS=&nc DOCK=5 OUT=treeout NOPRINT;
				COPY &inputs &group;
			RUN;
			PROC FREQ Data=treeout;
					TABLES &group*cluster /NOROW NOCOL NOPERCENT CHISQ OUT=freqout;
				OUTPUT OUT=stats chisq;
			RUN;
			DATA TEMP SUM;
				SET FREQOUT END=eof;
				BY &group;
				RETAIN MEMBERS MODE C;
					IF first.&group THEN DO;
						MEMBERS=0; MODE=0;
					END;
					MEMBERS=MEMBERS+COUNT;
					IF CLUSTER NE . THEN DO;
						IF COUNT > MODE THEN DO;
						MODE=COUNT;
						C=CLUSTER;
						END;
					END;
					IF last.&group THEN DO;
						CUM + (MEMBERS-MODE);
						OUTPUT TEMP;
					END;
					IF eof THEN OUTPUT SUM;
			RUN;
			PROC PRINT Data=temp NOOBS;
				VAR &group C MEMBERS MODE CUM;
			RUN;
			DATA Result;
				MERGE SUM (keep=cum) STATS;
				IF 0 THEN Modify result;
				METHOD = "&method";
				MISCLASSIFIED =CUM;
				CHISQ = _pchi_;
				PCHISQ = p_pchi;
				CRAMERS= _cramv_;
				OUTPUT RESULT;
			RUN;
			PROC PRINCOMP Data=treeout OUT=pcaout NOPRINT;
				VAR &inputs;
			RUN;
			PROC GPLOT Data=pcaout;
				PLOT PRIN2*PRIN1=cluster;
			RUN;
%mend scorecluster;

/*Define the fields to be retained in the Result dataset*/

LIBNAME VARRED "C:\Users\sdasmoh\Documents\Courses\IAA courses 2013-2014\Week 3 Cluster Analysis";
DATA work.iris;
	SET VARRED.iris;
RUN;

Data result;
	Length Method$ 12;
	Length Misclassified 8;
	Length chisq 8;
	Length pchisq 8;
	Length cramers 8;
	STOP;
RUN;
/*set up &input and &group macro variables*/
%let inputs = sl sw  pl pw;
%let group=variety;

/*Range Standardize the dataset*/
PROC STDIZE data=work.iris METHOD=RANGE OUT=siris;
	VAR &inputs;
RUN;

/*A PCA Plot is Generated*/
PROC PRINCOMP Data=siris OUT=pcaout NOPRINT;
		VAR &inputs;
		
RUN;

TITLE 'PCA Plot of Iris Varieties';
PROC GPLOT Data=pcaout;
	PLOT PRIN2*PRIN1 =&group;
RUN;

/*Next scorecluster is called for each hierarchical clustering method*/
%scorecluster (dsn=siris, nc=3, METHOD=AVERAGE);
%scorecluster (dsn=siris, nc=3, METHOD=CENTROID);
%scorecluster (dsn=siris, nc=3, METHOD=COMPLETE);
%scorecluster (dsn=siris, nc=3, METHOD=DENSITY, k=6);
%scorecluster (dsn=siris, nc=3, METHOD=EML);
%scorecluster (dsn=siris, nc=3, METHOD=FLEXIBLE);
%scorecluster (dsn=siris, nc=3, METHOD=MCQUITTY);
%scorecluster (dsn=siris, nc=3, METHOD=MEDIAN);
%scorecluster (dsn=siris, nc=3, METHOD=SINGLE);
%scorecluster (dsn=siris, nc=3, METHOD=TWOSTAGE, k=6);
%scorecluster (dsn=siris, nc=3, METHOD=WARD);

PROC SORT Data=result;
	BY misclassified;
RUN;

TITLE 'Summary';
TITLE2 'Ordered by Number of Misclassifications';
PROC PRINT Data=Result;
RUN;
