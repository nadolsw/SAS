PROC FACTEX;
 	FACTORS
		Brand Price Scent Size Softener / nlev=3;
	MODEL estimate=(Brand Price Scent Size Softener) / minabs;
	SIZE design = minimum;
	EXAMINE confounding design; 
RUN; QUIT;

%MKTEX(3**4 2**1, N=162);

*RECOMMEND AGAINST USING SOFTENER AS A FACTOR?*;

PROC FACTEX;
 	FACTORS
		Brand Price Scent Size / nlev=3;
	MODEL estimate=(Brand Price Scent Size) / minabs;
	SIZE design = minimum;
	OUTPUT OUT=work.two10m6
	Brand		cvals = ('Complete' 'Smile' 'Wave')
	Price	 	nvals = (2.99 3.99 4.99)
	Scent 		cvals = ('Lemon' 'Fresh' 'Unscented')
	Size		nvals = (32 48 64);
RUN; QUIT;


%MKTEX(3**4, N=9);

DATA key;
	LENGTH Scent $10.;
	INFILE datalines delimiter=",";
	INPUT Brand $ Price Scent $ Size;
	DATALINES;
Complete,2.99,Lemon,32
Smile,3.99,Fresh,48
Wave,4.99,Unscented,64
;
RUN; 

%mktlab(data=design, key=key)

%MKTRUNS(3**4);
