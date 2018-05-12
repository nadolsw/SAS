/*----------------------------------------------------*\
 |                                                    |
 |   Copyright (c) 2011 SAS Institute, Inc.           |
 |   Cary, N.C. USA 27513-8000                        |
 |   all rights reserved                              |
 |                                                    |
 |   THIS PROGRAM IS PROVIDED BY THE INSTITUTE "AS IS"|
 |   WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR|
 |   IMPLIED, INCLUDING BUT NOT LIMITED TO THE        |
 |   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS|
 |   FOR A PARTICULAR PURPOSE.  RECIPIENTS ACKNOWLEDGE|
 |   AND AGREE THAT THE INSTITUTE SHALL NOT BE LIABLE |
 |   WHATSOEVER FOR ANY DAMAGES ARISING OUT OF THEIR  |
 |   USE OF THIS PROGRAM.                             |
 |                                                    |
\*----------------------------------------------------*/
/*----------------------------------------------------*\
 |              S A S    T R A I N I N G              |
 |                                                    |
 |    NAME: GeneralUtilities.sas                      |
 |   TITLE: Utility Macros for IBT Courses            |
 |  SYSTEM: ALL (Windows pathname)                    |
 |    KEYS:                                           |
 |  COURSE: ALL                                       |
 |    DATA: None                                      |
 |                                                    |
 | SUPPORT: TJW                    UPDATE: 01JAN2011  |
 |     REF:                                           |
 |    MISC:                                           |
 |                                                    |
 |----------------------------------------------------|
 |   NOTES                                            |
 |----------------------------------------------------|
 |   If used for course XXXX, should be compiled      |
 |   in XXXX.sas start up code.                       |
\*----------------------------------------------------*/

/*----  Flag a term as having all digits or not  ----*/
%macro IsDigits(Token,Flag);
   length Kl99i0 Index55t2 4;
   drop Kl99i0 Index55t2;
   Kl99i0=length(&Token);
   &Flag=1;
   do Index55t2=1 to Kl99i0;
      if (not ('0'<=substr(&Token,Index55t2,1)<='9')) then do;
         &Flag=0;
         Index55t2=Kl99i0;
     end;
   end;
%mend IsDigits;

/*----  Count the number of words in a character string  ----*/
/*----  Originally written by: Rich Pletcher             ----*/
%macro NumberWords(String,Delimiter);
   %let _NumberWords = 0;
    
   %if %nrbquote(&String) eq %then %do;
    %goto exit;
   %end;
    
   %if %str(&Delimiter) eq %then %do; 
     
      %do %until(%bquote(%scan(%bquote(&String),
                 %eval(&_NumberWords+1),
                 %str( ))) eq );
         %let _NumberWords = %eval(&_NumberWords + 1);
      %end;
    
   %end;
   %else %do;
     
      %do %until(%bquote(%scan(%bquote(&String),
                 %eval(&_NumberWords+1),
                 %str(&Delimiter))) eq %str( ) );
         %let _NumberWords = %eval(&_NumberWords + 1);
      %end;
    
   %end;
    
%exit:  
   &_NumberWords
%mend NumberWords;

/*----  Original Author: Jim Georges  ----*/

%macro AddPrefixToList(MList,Prefix);
   &Prefix%sysfunc(tranwrd(%cmpres(&MList),%str( ),%str( &Prefix)))
%mend AddPrefixToList;

/*----  See NumberWords Above, Special Case Delimiter Blank  ----*/
%macro NumInList(MList);
   %let i=0;
   %do %while(%scan(&MList,%eval(&i+1))^=);
      %let i=%eval(&i+1);
   %end;
   &i
%mend NumInList;

/*----  Store words in a character string in unique macro vars  ----*/
/*----  Originally written by: Rich Pletcher                    ----*/
%macro ListValues(String=,Prefix=);
   %let Words = %NumberWords(&String);
   %global ListLength;
   %let ListLength = &Words;
   %do _l_ = 1 %to &Words;
      %global &Prefix.&_l_ ;
      %let &Prefix.&_l_ = %scan(&String,&_l_,%str( ));
   %end;
%mend;

%macro ConcatVars(Varlist,NewVar);
   %let ListLength = %NumberWords(&VarList);
   &NewVar=compress(strip(%scan(&VarList,1,%str( )))
   %do _l_ = 2 %to &ListLength;
      ||strip(%scan(&VarList,&_l_,%str( )))
   %end;
   );
%mend ConcatVars;

%macro CreateVarList(Prefix,Number);
   %do _l_=1 %to &Number;
      &Prefix.&_l_
   %end;
%mend CreateVarList;

%macro CreateCharList(MacVar,Prefix);
   %let Number=NumInList(&MacVar);
   %do _l_=1 %to &Number;
      &Prefix.%scan(&MacVar,_l_,%str( ));
   %end;
%mend CreateCharList;

%macro GenList(Prefix,Start,Stop);
   %do _l_=&Start %to &Stop;
      &Prefix.&_l_
   %end;
%mend GenList;

%macro GenList2(Prefix,Start,Stop);
   %do _l_=&Start %to &Stop;
      %if (%eval(&_l_+0)<10) %then %do;
         &Prefix.0&_l_
      %end;
      %else %do;
         &Prefix.&_l_
      %end;
   %end;
%mend GenList2;

%macro CreateVarList2(Prefix,Number);
   %do _l_=1 %to &Number;
      %if (%eval(&_l_+0)<10) %then %do;
         &Prefix.0&_l_
      %end;
      %else %do;
         &Prefix.&_l_
      %end;
   %end;
%mend CreateVarList2;

%macro ListDigits(Number);
   %do _l_=1 %to &Number;
      &_l_
   %end;
%mend ListDigits;

/*---------------------------------*\
 |  Usage:                         |
 |  %global MyFlag;                |
 |  %IsODS_HTML(MyFlag);           |
 |  %if (&MyFlag) %then %do;       |
 |     ...                         |
\*---------------------------------*/
%macro IsODS_HTML(HTMLflag);
   proc sql noprint;
      select DESTINATION into :MyDestination
      from sashelp.vdest;
   quit;
   %if (%upcase(&MyDestination) eq HTML) %then %do;
      %let &HTMLflag=1;
   %end;
   %else %do;
      %let &HTMLflag=0;
   %end;
%mend;

%macro GetURLs(DSName=,URLref=,FTPflag=N,Proxy=,UserID=,Password=);
   %if (%upcase(&FTPflag) eq N) %then %do;
      filename WebInput url "http://&URLref"
   %end;
   %else %do;
      filename WebInput ftp "ftp://&URLref"
   %end;
   %if (&Proxy ne ) %then %do;
            proxy="&Proxy"
   %end;
   %if (&UserID ne ) and (&Password ne ) %then %do;
            user="&UserID" pass="&PassWord"
   %end;
            ;
   /*----  Read the file into a SAS datset  ----*/
   data work.tempurl;
      attrib Inbyte length=$1;
      infile WebInput lrecl=1 recfm=f;
      input Inbyte $char1.;
   run;

   %let NumObs=%GetNumObs(work.tempurl);
   %put &URLref;
   %put &NumObs;
   %put ---------------;
   %if (&NumObs eq 0) %then %do;
      data &DSName;
         attrib TEXT length=$32767
                URL  length=$512;
         URL="&URLref";
         TEXT="";
      run;
   %end;
   %else %do;
      data &DSName;
         set work.tempurl end=lastobs;
         attrib TEXT length=$32767
                URL  length=$512;
         retain TEXT;
         substr(TEXT,_N_,1)=Inbyte;
         if (lastobs) then do;
            URL="&URLref";
            output;
         end;
         keep URL TEXT;
      run;
   %end;
   proc datasets library=work;
      delete tempurl;
   run;
   quit;
%mend GetURLs;

/*
DSName=input data set containing URL
VarName=name of character variable containing URL
OutDS=output SAS table containing URL and Text fields
*/
%macro GetURLsAll(DSName=,VarName=,OutDS=,Proxy=,UserID=,Password=);
   %let NumObs=%GetNumObs(&DSName);
   %do LineNo=1 %to &NumObs;
      data _null_;
         set &DSName(firstobs=&LineNo obs=&LineNo);
         call symput("TargetURL",strip(&VarName));
      run;
      
      %if (&LineNo eq 1) %then %do;
         %GetURLs(DSName=&OutDS,URLref=&TargetURL,
                  Proxy=&Proxy,UserID=&UserID,Password=&Password);
      %end;
      %else %do;
         %GetURLs(DSName=work.tempone,URLref=&TargetURL,
                  Proxy=&Proxy,UserID=&UserID,Password=&Password);
         proc append base=&OutDS data=work.tempone;
         run;
      %end;
   %end;
   proc datasets library=work;
      delete tempone;
   run;
   quit;
%mend GetURLsAll;

%macro CopyURL2Disk(FileName=,URLref=,FTPflag=N,Proxy=,UserID=,Password=);
   %if (%upcase(&FTPflag) eq N) %then %do;
      filename WebInput url "%nrquote(&URLref)"
   %end;
   %else %do;
      filename WebInput ftp "%nrquote(&URLref)"
   %end;
   %if (&Proxy ne ) %then %do;
            proxy="&Proxy"
   %end;
   %if (&UserID ne ) and (&Password ne ) %then %do;
            user="&UserID" pass="&PassWord"
   %end;
            ;
   /*----  Read the file into a SAS datset  ----*/
   data work.tempurl;
      attrib Inbyte length=$1;
      infile WebInput lrecl=1 recfm=f;
      input Inbyte $char1.;
   run;
   /*----  Write file to disk  ----*/
   %let NumObs=%GetNumObs(work.tempurl);
   %if (&NumObs eq 0) %then %do;
      %put ERROR: Unable to read %nrquote(&URLref).;
   %end;
   %else %do;
      data _null_;
         set work.tempurl;
         file "&FileName";
         put Inbyte $char1. @;
      run; 
   %end;
   %DeleteDS(work.tempurl);
%mend CopyURL2Disk;

%put GeneralUtilities.sas Loaded;

/*--------------------------*/
/*----  End of program  ----*/
/*--------------------------*/

/*----------------------------------------------------*\
 |                                                    |
 |   Copyright (c) 2011 SAS Institute, Inc.           |
 |   Cary, N.C. USA 27513-8000                        |
 |   all rights reserved                              |
 |                                                    |
 |   THIS PROGRAM IS PROVIDED BY THE INSTITUTE "AS IS"|
 |   WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR|
 |   IMPLIED, INCLUDING BUT NOT LIMITED TO THE        |
 |   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS|
 |   FOR A PARTICULAR PURPOSE.  RECIPIENTS ACKNOWLEDGE|
 |   AND AGREE THAT THE INSTITUTE SHALL NOT BE LIABLE |
 |   WHATSOEVER FOR ANY DAMAGES ARISING OUT OF THEIR  |
 |   USE OF THIS PROGRAM.                             |
 |                                                    |
\*----------------------------------------------------*/
/*----------------------------------------------------*\
 |              S A S    T R A I N I N G              |
 |                                                    |
 |    NAME: FileUtilities.sas                         |
 |   TITLE: File Utility Macros                       |
 |  SYSTEM: ALL (Windows pathname)                    |
 |    KEYS:                                           |
 |  COURSE: Any                                       |
 |    DATA: NA                                        |
 |                                                    |
 | SUPPORT: TJW                    UPDATE: 29AUG2011  |
 |     REF:                                           |
 |    MISC:                                           |
 |                                                    |
 |----------------------------------------------------|
 |   NOTES                                            |
 |----------------------------------------------------|
 |   If used for course XXXX, should be compiled      |
 |   in XXXX.sas start up code.                       |
\*----------------------------------------------------*/

/*-----------------------------------------------------------*/
/*----  Existence of external file: 1=exists, 0=doesn't  ----*/
/*----  Example: Boolean=%ExistFile(C:\temp\file);       ----*/
/*----  Returns FALSE (zero=0) if the dataset does not   ----*/
/*----  exist, TRUE (one=1) otherwise. Valid in dataset  ----*/
/*----  or macro code.                                   ----*/
/*-----------------------------------------------------------*/
%macro ExistFile(FileName);
   %sysfunc(fileexist(&FileName))
%mend ExistFile;

%macro ExistFileRef(FileRef);
   %sysfunc(fexist(&FileRef))
%mend ExistFileRef;

/*----  Returns 0 or 1, 1=path is a directory  ----*/
%macro ExistDirectory(Path=);
   %let FileRef=MYDIR;
   %let RC=%sysfunc(filename(FileRef,&Path));
   %let DID=%sysfunc(dopen(&FileRef));
   %let RC=%sysfunc(dclose(&DID));
   &DID
%mend ExistDirectory;

%macro EraseFile(FileName);
   %if (%ExistFile(&FileName)) %then %do;
      %let FREFMAC=%RandSASName();
      filename &FREFMAC "&FileName";
      %let DUMMY=%sysfunc(fdelete(&FREFMAC));
      filename &FREFMAC clear;
   %end;
%mend EraseFile;

%macro EraseFileRef(FileRef);
   %if (%ExistFileRef(&FileRef)) %then %do;
      %let DUMMY=%sysfunc(fdelete(&FileRef));
      filename &FileRef clear;
   %end;
%mend EraseFileRef;


/*-----------------------------------------------------------*/
/*----  Existence of PROC: YES=exists, NO=does not       ----*/
/*----  Example: %ProcExist(IML,DoesItExist);            ----*/
/*----  Returns YES if PROC IML exists, NO if PROC IML   ----*/
/*----  does not exist.                                  ----*/
/*----  NOTE: Made obsolete by %SYSPROD, but still can   ----*/
/*----        be used at the PROC level when the         ----*/
/*----        product name is not known.                 ----*/
/*-----------------------------------------------------------*/
/*----  Old: %ProcExist(NPL,YesNo)                       ----*/
/*----  New  %ProcExist(NPL,YesNo) if unsure of NPL prod ----*/
/*----  Old: %ProcExist(IML,YesNo)                       ----*/
/*----  New  %if (%sysprod(iml)=1) %then ....            ----*/
/*-----------------------------------------------------------*/
%macro ProcExist(ProcName,YesNo);
   data _null_;
      call symput("&YesNo","YES");
   run;
   %let OutputLog=%RanWinFile(Suffix=log);
   filename LogFile "&OutputLog";

   proc printto log=LogFile;
   run;
   proc &ProcName;
   run;
   proc printto;
   run;
   data _null_;
      attrib LINE length=$256;
      infile LogFile;
      input;
      LINE=_infile_;
      if (index(LINE,"ERROR: Procedure &ProcName not found.")>0)
         then do;
         call symput("&YesNo","NO");
         stop;
      end;
   run;
   filename LogFile clear;
   %EraseFile(&OutputLog);
%mend ProcExist;
/*
   options nomprint nosymbolgen;
   options mprint symbolgen;
   %global DoesItExist;
   %ProcExist(SUMMARY,DoesItExist);
   %put SUMMARY &DoesItExist;
   %ProcExist(IML,DoesItExist);
   %put IML &DoesItExist;
   %ProcExist(SHAZZAM,DoesItExist);
   %put SHAZZAM &DoesItExist;
   %if (%sysprod(IML)=1) %then %do;
      %let DoesItExist=YES;
   %end;
   %else %do;
      %let DoesItExist=NO;
   %end;
   %put IML &DoesItExist;
 */

/*-----------------------------------------------------*/
/*----  Get number of observations in a data set.  ----*/
/*----  Example: NumObs=%GetNumObs(WORK.TEMP);     ----*/
/*----  Returns zero (0) if the dataset does not   ----*/
/*----  exist. Valid in dataset or macro code.     ----*/
/*-----------------------------------------------------*/
%macro GetNumObs(DSNAME);
   %local DSID RC;
   %if %sysfunc(exist(&DSNAME)) %then %do;
      %let DSID=%sysfunc(open(&DSNAME));
      %if (&DSID eq 0) %then %do;
         0
      %end;
      %else %do;
         %sysfunc(attrn(&DSID,NOBS))
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
      %end;
   %end;
   %else %do;
      0
   %end;
%mend GetNumObs;

/*-----------------------------------------------------*/
/*----  Get maximum number of observations for BY  ----*/
/*----  groups.                                    ----*/
/*----  Example:                                   ----*/
/*----  %global MaxByNumObs;                       ----*/
/*----  GetMaxByNumObs(MyLib.Transactions,CustID); ----*/
/*----  Set macro variable to zero (0) if the      ----*/
/*----  dataset does not exist.                    ----*/
/*-----------------------------------------------------*/
/*  Required: %global MaxByNumObs; */
%macro GetMaxByNumObs(DSName,IDName);
%if %sysfunc(exist(&DSNAME)) %then %do;
   proc sql noprint;
      select max(number) into :MaxByNumObs
      from ( select count(*) as number from &DSName
             group by &IDName);
   quit;
%end;
%else %let MaxByNumObs=0;
%mend GetMaxByNumObs;

/*----  Get the Label for a SAS Table  ----*/
%macro GetDataLabel(DSNAME);
   %local DSID RC;
   %if %sysfunc(exist(&DSNAME)) %then %do;
      %let DSID=%sysfunc(open(&DSNAME));
      %if (&DSID eq 0) %then %do;
         %str( )
      %end;
      %else %do;
         %sysfunc(attrc(&DSID,LABEL))
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
      %end;
   %end;
   %else %do;
      %str( )
   %end;
%mend GetDataLabel;



/*-----------------------------------------------------*/
/*----  Get cardinality of a variable.             ----*/
/*----  Example: %global Cardinality;              ----*/
/*----           %GetCardinality(work.temp,Prd_ID);----*/
/*----                                             ----*/
/*-----------------------------------------------------*/
%macro GetCardinality(DSName,VarName);
   %let TempData=%RandWorkData();
   proc freq data=&DSName noprint;
      table &VarName/out=&TempData;
   run;
   %let Cardinality=%GetNumObs(&TempData);
   %DeleteDS(&TempData);
%mend GetCardinality;

%macro DataCardinality(DSName,OutData);
   %let TempData=%RandWorkData();
   proc contents data=&DSName noprint out=&TempData;
   run;
   data &TempData;
      set &TempData;
      where (TYPE=2);
   run;
   data _null_;
      attrib AllChar length=$256;
      set &TempData end=lastobs;
      retain AllChar '';
      AllChar=strip(AllChar)||' '||Name;
      if (lastobs) then do;
         call symput("BigStr",AllChar);
      end;
   run;
   %global Cardinality;
   %let i=0;
   %do %while("%scan(&BigStr,%eval(&i+1),%str( ))" ne "");
      %let VarName=%scan(&BigStr,%eval(&i+1),%str( ));
      %GetCardinality(&DSName,&VarName);
      %let i=%eval(&i+1);
      %if (&i eq 1) %then %do;
         data &OutData;
            attrib Name length=$32
                   Cardinality length=8;
            Name="&VarName";
            Cardinality=&Cardinality;
            output;
         run;
      %end;
      %else %do;
         data &OutData;
            set &OutData end=lastobs;
            output;
            if (lastobs) then do;
               Name="&VarName";
               Cardinality=&Cardinality;
               output;
            end;
         run;
      %end;
   %end;
%mend DataCardinality;

/*----  Example  ---- 
%let AllVars=%cmpres(%GetAllVars(work.D_5317));
%put &AllVars;
 *-------------------*/
%macro GetAllVars(DSName);
   %local DSID RC VNum NumVars;
   %if %eval(%sysfunc(exist(&DSName,DATA)) eq 1) or
       %eval(%sysfunc(exist(&DSName,VIEW)) eq 1) %then %do;
      %let DSID=%sysfunc(open(&DSName));
      %if (&DSID eq 0) %then %do;
         %let NumVars=0;
      %end;
      %else %do;
         %let NumVars=%sysfunc(attrn(&DSID,NVARS));
         %do VNum=1 %to &NumVars;
             %sysfunc(varname(&dsid,&VNum))
         %end;
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
      %end;
   %end;
%mend GetAllVars;


/*----  Example  ---- 
%let NumericVars=%cmpres(%GetNumericVars(work.D_5317));
%put &NumericVars;
 *-------------------*/

%macro GetNumericVars(DSName);
   %local DSID RC VType VNum NumVars;
   %if %sysfunc(exist(&DSName)) %then %do;
      %let DSID=%sysfunc(open(&DSName));
      %if (&DSID eq 0) %then %do;
         %let NumVars=0;
      %end;
      %else %do;
         %let NumVars=%sysfunc(attrn(&DSID,NVARS));
         %do VNum=1 %to &NumVars;
            %let VType=%sysfunc(vartype(&dsid,&VNum));
            %if (&VType eq N) %then %do;
               %sysfunc(varname(&dsid,&VNum))
            %end;
         %end;
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
      %end;
   %end;
%mend GetNumericVars;

/*----  Example  ----
%let CharVars=%cmpres(%GetCharacterVars(work.D_5302));
%let NumCharacter=%NumInList(&CharVars);
%put &CharVars;
 *-------------------*/
%macro GetCharacterVars(DSName);
   %local DSID RC VType VNum NumVars;
   %if %sysfunc(exist(&DSNAME)) %then %do;
      %let DSID=%sysfunc(open(&DSNAME));
      %if (&DSID eq 0) %then %do;
         %let NumVars=0;
      %end;
      %else %do;
         %let NumVars=%sysfunc(attrn(&DSID,NVARS));
         %do VNum=1 %to &NumVars;
            %let VType=%sysfunc(vartype(&dsid,&VNum));
            %if (&VType eq C) %then %do;
               %sysfunc(varname(&dsid,&VNum))
            %end;
         %end;
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
      %end;
   %end;
%mend GetCharacterVars;

/*----  Drop Variables Having a Given Label  ----*/
%macro DropLabeledVars(DSName=,LabelString=);
   %let RandWork=%RandWorkData();
   proc contents data=&DSName out=&RandWork noprint;
   run;
   data &RandWork;
      set &RandWork;
      if (upcase(strip(LABEL))=upcase("&LabelString")) then output;
      keep NAME LABEL;
   run;
   %let NumberObs=%GetNumObs(&RandWork);
   %if (&NumberObs ne 0) %then %do;
      data _null_;
         attrib DropList length=$32000;
         set &RandWork end=lastobs;
         retain didit 0 DropList ' ';
         DropList=strip(DropList)||' '||NAME;
         if (lastobs) then do;
            call symput("NDropList",DropList);
         end;
      run;
      data &DSName;
         set &DSName;
         drop &NDropList;
      run;
   %end;
   %DeleteDS(&RandWork);
%mend DropLabeledVars;

/*---- Drop all numeric and/or character variables with a            ----*/
/*---- missing/blank percentage at or above a PercentMissing cutoff  ----*/
%macro DropBlankVars(DSName=,PercentMissing=100);
   %let RandWork=%RandWorkData();
   /*----  First Numeric Variables  ----*/
   %let NumericVars=%cmpres(%GetNumericVars(&DSName));
   %let NumNumeric=%NumInList(&NumericVars);
   %if (&NumNumeric ne 0) %then %do;
      %let NumberObs=%GetNumObs(&DSName);
      proc summary data=&DSName NMISS;
         var &NumericVars;
         output out=&RandWork(drop=_TYPE_ _FREQ_)
              NMISS=%AddPrefixToList(&NumericVars,NM_);
      run;
      data _null_;
         attrib DropList length=$32000;
         set &RandWork;
         retain DropList ' ';
         %do _i_=1 %to &NumNumeric;
            %let ThisVar=%scan(&NumericVars,&_i_);
            if (100*NM_&ThisVar/&NumberObs >= &PercentMissing)
               then do;
               DropList=strip(DropList)||' '||"&ThisVar";
            end; 
         %end;
         call symput("NDropList",DropList);
      run;
      %let NumDrop=%NumInList(&NDropList);
      %if (&NumDrop ne 0) %then %do;
         data &DSName; 
            set &DSName; 
            drop &NDropList ; 
         run;
      %end;
      %DeleteDS(&RandWork);
   %end;
   /*----  Second Character Variables  ----*/
   %let CharacterVars=%cmpres(%GetCharacterVars(&DSName));
   %let NumCharacter=%NumInList(&CharacterVars);
   %if (&NumCharacter ne 0) %then %do;
      %let RandBase=&RandWork.B;
      %do _i_=1 %to &NumCharacter;
         %let ThisVar=%scan(&CharacterVars,&_i_);
         proc freq data=&DSName noprint;
            table &ThisVar / missing out=&RandWork;
         run;
         data &RandWork;
            attrib VarName length=$32;
            set &RandWork(where=(&ThisVar=' '));
            VarName="&ThisVar";
            keep VarName Percent;
         run;
         proc append base=&RandBase data=&RandWork;
         run;
      %end;
      data &RandBase;
         attrib DropList length=$32000;
         set &RandBase;
         retain DropList ' ';
         if (Percent >= &PercentMissing) then do;
            DropList=strip(DropList)||' '||strip(VarName);
         end; 
         call symput("NDropList",DropList);
      run;

      %let NumDrop=%NumInList(&NDropList);
      %if (&NumDrop ne 0) %then %do;
         data &DSName; 
            set &DSName; 
            drop &NDropList ; 
         run;
      %end;
      %DeleteDS(&RandWork);
      %DeleteDS(&RandBase);
   %end;
%mend DropBlankVars;

/*----------------------------------------------------*/
/*----  Get number of variables in a data set.    ----*/
/*----  Example: NumVars=%GetNumVars(WORK.TEMP);  ----*/
/*----  Returns zero (0) if the dataset does not  ----*/
/*----  exist. Valid in dataset or macro code.    ----*/
/*----------------------------------------------------*/
%macro GetNumVars(DSName);
   %local DSID RC;
   %if %sysfunc(exist(&DSName)) %then %do;
      %let DSID=%sysfunc(open(&DSName));
      %if (&DSID eq 0) %then %do;
         0
      %end;
      %else %do;
         %sysfunc(attrn(&DSID,NVARS))
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
      %end;
   %end;
   %else %do;
      0
   %end;
%mend GetNumVars;

%macro GetVarType(DSName,Varname);
   %local DSID RC VType;
   %if %sysfunc(exist(&DSName)) %then %do;
      %let DSID=%sysfunc(open(&DSName,i));
      %if (&DSID eq 0) %then %do;
         0
      %end;
      %else %do;
         %let VNum=%sysfunc(varnum(&dsid,&Varname));
         %if ("&VNum" eq "0") %then %do;
            %let VType=0;
         %end;
         %else %do;
            %let VType=%sysfunc(vartype(&dsid,&VNum));
         %end;
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
         &VType
      %end;
   %end;
   %else %do;
      0
   %end;
%mend GetVarType;

%macro GetVarLength(DSName,Varname);
   %local DSID RC VLength;
   %if %sysfunc(exist(&DSName)) %then %do;
      %let DSID=%sysfunc(open(&DSName,i));
      %if (&DSID eq 0) %then %do;
         0
      %end;
      %else %do;
         %let VNum=%sysfunc(varnum(&dsid,&Varname));
         %if ("&VNum" eq "0") %then %do;
            %let VLength=0;
         %end;
         %else %do;
            %let VLength=%sysfunc(varlen(&dsid,&VNum));
         %end;
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
         &VLength
      %end;
   %end;
   %else %do;
      0
   %end;
%mend GetVarLength;

%macro GetVarLabel(DSName,Varname);
   %local DSID RC VLabel;
   %if %sysfunc(exist(&DSName)) %then %do;
      %let DSID=%sysfunc(open(&DSName,i));
      %if (&DSID eq 0) %then %do;
         0
      %end;
      %else %do;
         %let VNum=%sysfunc(varnum(&dsid,&Varname));
         %if ("&VNum" eq "0") %then %do;
            %let VLabel=0;
         %end;
         %else %do;
            %let VLabel=%sysfunc(varlabel(&dsid,&VNum));
         %end;
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
         &VLabel
      %end;
   %end;
   %else %do;
      0
   %end;
%mend GetVarLabel;

%macro GetVarFormat(DSName,Varname);
   %local DSID RC VFormat;
   %if %sysfunc(exist(&DSName)) %then %do;
      %let DSID=%sysfunc(open(&DSName,i));
      %if (&DSID eq 0) %then %do;
         0
      %end;
      %else %do;
         %let VNum=%sysfunc(varnum(&dsid,&Varname));
         %if ("&VNum" eq "0") %then %do;
            %let VFormat=0;
         %end;
         %else %do;
            %let VFormat=%sysfunc(varfmt(&dsid,&VNum));
         %end;
         /*----  Must use LET because close has a return code  ----*/
         %let RC=%sysfunc(close(&DSID));
         &VFormat
      %end;
   %end;
   %else %do;
      0
   %end;
%mend GetVarFormat;

/*--------------------------------------------------*/
/*----  Store all variable names in a data set  ----*/
/*----  in macro variable AllVariables.         ----*/
/*--------------------------------------------------*/
/*----  %global AllVariables;                   ----*/
/*----  %ListAllVars(work.MyData);              ----*/
/*----  %put &AllVariables;                     ----*/
/*--------------------------------------------------*/
%macro ListAllVars(DSName);
   %local DSID RC;
   %if %sysfunc(exist(&DSNAME)) %then %do;
      %let DSID=%sysfunc(open(&DSNAME,i));
      %if (&DSID eq 0) %then %do;
         0
      %end;
      %let NumVars=%GetNumVars(&DSName);
      %let AllVariables=%sysfunc(varname(&DSID,1));
      %do VarNum=2 %to &NumVars;
         %let AllVariables=&AllVariables %sysfunc(varname(&DSID,&VarNum));
      %end;
      %let RC=%sysfunc(close(&DSID));
   %end;
   %else %do;
      0
   %end;
%mend ListAllVars;

/*-------------------------------------------*/
/*----  List variable names to log file  ----*/
/*-------------------------------------------*/
%macro ListVars(DSName);
   %let TempData=%RandWorkData();
   proc contents data=&DSName out=&TempData noprint;
   run;
   data _null_;
      set &TempData;
      put @1 NAME;
   run;
   %DeleteDS(&TempData);
%mend ListVars;

%macro ListVarsColNum(DSName,ColNum);
   %let TempData=%RandWorkData();
   proc contents data=&DSName out=&TempData noprint;
   run;
   data _null_;
      set &TempData;
      put @&ColNum NAME;
   run;
   %DeleteDS(&TempData);
%mend ListVarsColNum;

/*----  Write names of files in a folder to a SAS data set  ----*/
%macro WriteDirDS(FolderName,DSName);
   filename inpfile pipe "dir ""&FolderName"" /b /d" console=min;
   data &DSName;
      attrib LINE     length=$512
             FILENAME length=$512;
      infile inpfile;
      input;
      LINE=_infile_;
      FILENAME=strip(LINE);
      output;
      keep FILENAME;
   run;
   filename inpfile clear;
%mend WriteDirDS;

/*----  Write complete path of folder or file to SAS data set  ----*/

%macro WriteDirDSsub(FolderName,DSName);
   filename inpfile pipe "dir ""&FolderName"" /b /s" console=min;
   data &DSName;
      attrib LINE     length=$2048
             FILENAME length=$2048;
      infile inpfile;
      input;
      LINE=_infile_;
      FILENAME=strip(LINE);
      output;
      keep FILENAME;
   run;
   filename inpfile clear;
%mend WriteDirDSsub;

/*----  Store path, file name, and SAS data set name    ----*/
/*----  derived from a parent folder in a SAS data set. ----*/
%macro FindAllSASData(FolderName,DSName);
   %let IsDirectory=%ExistDirectory(Path=&FolderName);
   %if (&IsDirectory eq 1) %then %do;
      filename inpfile pipe "dir ""&FolderName"" /b /s" console=min;
      data &DSName;
         attrib LINE     length=$2048
                FOLDER   length=$2048
                FILENAME length=$2048
                SASNAME  length=$32;
         infile inpfile;
         input;
         LINE=_infile_;
         FOLDER=strip(LINE);

         FILENAME=strip(scan(FOLDER,-1,'\'));
         i=index(FILENAME,'.sas7bdat');
         if (i>0) then do;
            pointer=index(FOLDER,strip(FILENAME));
            FOLDER=substr(FOLDER,1,pointer-1);
            SASNAME=substr(FILENAME,1,i-1);
            output;
         end;
         keep FOLDER FILENAME SASNAME;
      run;
      filename inpfile clear;
   %end;
   %else %do;
      %put ERROR: In macro FindAllSASData, path &FolderName is not a directory.;
   %end;
%mend FindAllSASData;

/*----  Write names of files in a folder to an external file  ----*/
%macro WriteDirFile(FolderName,FileName);
   %EraseFile(&FileName);
   filename inpfile pipe "dir ""&FolderName"" /b /d" console=min;
   filename outpfile "&FileName";
   data _NULL_;
      attrib LINE     length=$512
             FILENAME length=$512;
      infile inpfile;
      file outpfile;
      input;
      LINE=_infile_;
      FILENAME=strip(LINE);
      put @1 FILENAME;
   run;
   filename inpfile clear;
   filename outpfile clear;
%mend WriteDirFile;

/*----  CONTENTs of All SAS Data Sets in a Folder  ----*/

%macro FolderContents(FolderName);
   %let TempLib=%RandSASName();
   libname &TempLib "&FolderName";
   %let RandData=%RandWorkData();
   %WriteDirDS(&FolderName,&RandData);
   %let NumberObs=%GetNumObs(&RandData);
   %if (&NumberObs ne 0) %then %do;
      data _null_;
         attrib ExecCode length=$32000
                SASDS    length=$32;
         set &RandData;
         i=index(FILENAME,".sas7bdat");
         if (i>0) then do;
            SASDS=strip("&TempLib")||'.'||substr(FILENAME,1,i-1);
            ExecCode="proc contents data="||strip(SASDS)||"; run;";
            call execute(ExecCode);
         end;
      run;
   %end;
   libname &TempLib CLEAR;
   %DeleteDS(&RandData);
%mend FolderContents;
/*----  Store Names of SAS data sets in a folder in a SAS data set  ----*/
%macro GetSASDataNames(FolderName,DSName);
   filename inpfile pipe "dir ""&FolderName"" /b /d" console=min;
   data &DSName;
      attrib LINE     length=$512
             FileName length=$512  label="File Name"
             SASName  length=$64   label="SAS Data Set Name"
             Suffix   length=$512;
      infile inpfile;
      input;
      LINE=_infile_;
      FileName=trim(left(LINE));
      pointer=index(FileName,".sas7bdat");
      if (pointer>0) then Suffix=substr(FileName,pointer);
      else Suffix="";
      if (Suffix=".sas7bdat") then do;
         SASName=substr(FileName,1,pointer-1);
         output;
      end;
      keep FileName SASName;
   run;
   proc sort data=&DSName;
      by FileName;
   run;
   filename inpfile clear;
%mend GetSASDataNames;

/*----  Summarize SAS Data Sets residing in a Folder.  ----*/
/*----  If OutDS exists, it will be replaced.          ----*/
%macro SASDataVarsObs(FolderName,OutDS);
   %DeleteDS(&OutDS);
   %let TempLib=%RandSASName();
   libname &TempLib "&FolderName";
   %let RandData=%RandWorkData();
   %let RandBase=&RandData.B;
   %WriteDirDS(&FolderName,&RandData);
   %let NumberObs=%GetNumObs(&RandData);
   %if (&NumberObs ne 0) %then %do;
      data &RandData;
         attrib SASDS    length=$32;
         set &RandData;
         i=index(FILENAME,".sas7bdat");
         if (i>0) then do;
            SASDS=strip("&TempLib")||'.'||substr(FILENAME,1,i-1);
            output;
         end;
         drop i;
      run;
   %end;
   %let NumberObs=%GetNumObs(&RandData);
   %if (&NumberObs ne 0) %then %do;
      %do _i_=1 %to &NumberObs;
         data &RandBase;
            set &RandData(firstobs=&_i_ obs=&_i_);
            DSID=open(SASDS);
            if (DSID ne 0) then do;
               NumObs=attrn(DSID,"NOBS");
               NumVars=attrn(DSID,"NVARS");
               output;
               RC=close(DSID);
            end;
            else put "WARNING: Cannot open " SASDS;
            keep FILENAME NumObs NumVars;
         run;
         proc append base=&OutDS data=&RandBase;
         run;
      %end;
      proc print data=&OutDS;
      run;
   %end;
   libname &TempLib CLEAR;
   %DeleteDS(&RandData);
   %DeleteDS(&RandBase);
%mend SASDataVarsObs;

/*-----------------------------------------*\
  Modify Length of Character Variable

  If CharLen=0, pick size equal to length of
  longest character string.

  Required:

  %global MaxCharLen;
\*-----------------------------------------*/
%macro AdjustCharVar(DSName=,CharVar=,CharLen=0);
   %let TempData=%RandWorkData();
   proc contents data=&DSName out=&TempData noprint;
   run;
   data _null_;
      set &TempData;
      if (upcase(NAME)=upcase("&CharVar")) then do;
         if (length(strip(LABEL))<=1) then
            LABEL="&CharVar";
         call symput("CLabel",strip(LABEL));
         call symput("CLength",LENGTH);
         stop;
      end;
   run;
   %DeleteDS(&TempData);
   %if (&CharLen eq 0) %then %do;
   data _null_;
      set &DSName end=lastobs;
      retain MaxL 0;
      LL=length(strip(&CharVar));
      if (LL gt MaxL) then MaxL=LL;
      if (lastobs) then do;
         call symput("MaxCharLen",MaxL);
      end;
   run;
   %end;
   %else %do;
      %let MaxCharLen=&CharLen;
   %end;
   %if (%eval(&MaxCharLen ^= &CLength) eq 1) %then %do;;
      %if (%scan(&DSName,2,%str(.)) eq ) %then %do;
         %let NewDSName=work.&DSName;
      %end;
      %else %do;
         %let NewDSName=&DSName;
      %end;

      proc datasets library=%scan(&NewDSName,1,%str(.));
         modify %scan(&NewDSName,2,%str(.));
         rename &CharVar=old_&CharVar;
      run;
      quit;
      data &DSName(compress=Y);
         set &DSName;
         attrib &CharVar length=$&MaxCharLen label="&CLabel";
         &CharVar=strip(old_&CharVar);
         drop old_&CharVar;
      run;
      %put NOTE: In macro AdjustCharVar, &CharVar changed from length %sysfunc(strip(&CLength)) to length %sysfunc(strip(&MaxCharLen)).;
   %end;
   %else %do;
      %put NOTE: In macro AdjustCharVar, MaxLenth=&MaxCharLen, CLength=&CLength;
   %end;
%mend AdjustCharVar;

/*----------------------------------------------------------*/
/*----  For transactional data, multiple transactions   ----*/
/*----  per ID get the maximum number of transactions.  ----*/
/*----  %global max_records_per_case;                   ----*/
/*----------------------------------------------------------*/
%macro MaxTranRecords(DSNAME,IDNAME);
proc sql noprint;
   select max(number) into :max_records_per_case
   from ( select count(*) as number from &DSNAME
          group by &IDNAME);
quit;
%mend MaxTranRecords;

/*-------------------------------------------------*/
/*----  Make a Temporary Copy of Project Data  ----*/
/*----  Example: %WorkCopy(MyProject.MyData);  ----*/
/*----  Errors: (1) Data does not exist        ----*/
/*----          (2) Data is already in WORK    ----*/
/*----          (3) A WORK data set with that  ----*/
/*----              name already exists        ----*/
/*-------------------------------------------------*/
%macro WorkCopy(DSName);
   %local LNAME DNAME;
   %if %sysfunc(exist(&DSName)) %then %do;
      %let LNAME=%scan(&DSName,1,".");
      %let DNAME=%scan(&DSName,2,".");
      %if (&DNAME eq) or (%upcase(&LNAME) eq WORK) %then %do;
         %put ERROR: In macro WorkCopy---&DSName is a temporary data set.;
      %end;
      %else %if %sysfunc(exist(work.&DNAME)) %then %do;
         %put ERROR: In macro WorkCopy---work.&DNAME already exists.;
      %end;
      %else %do;
         data work.&DNAME;
            set &DSName;
         run;         
      %end;
   %end;
   %else %do;
      %put ERROR: In macro WorkCopy---&DSName does not exist.;
   %end;
%mend WorkCopy;

/*-------------------------------------------*/
/*----  Delete a data set.               ----*/
/*----  Example: %DeleteDS(work.temp);   ----*/
/*----  If the data set does not exist,  ----*/
/*----  PROC DATASETS will write a NOTE  ----*/
/*----  to the log (not a WARNING or     ----*/
/*----  ERROR).                          ----*/
/*-------------------------------------------*/
%macro DeleteDS(DSNAME);
   %local LNAME DNAME;
   %let LNAME=%scan(&DSNAME,1,".");
   %let DNAME=%scan(&DSNAME,2,".");
   %if (&DNAME eq) %then %do;
      proc datasets library=work nolist;
        delete &LNAME;
     run;
     quit;
   %end;
   %else %do;
      proc datasets library=&LNAME nolist;
        delete &DNAME;
     run;
     quit;
   %end;
%mend DeleteDS;



/*--------------------------------------------------------*/
/*----  Generate data step code that would reproduce  ----*/
/*----  characteristics of input data, except with    ----*/
/*----  variables in column order also in sort order. ----*/
/*--------------------------------------------------------*/

%macro ColumnSort(DSName=,OutDS=);
   %let ContentsData=%RandWorkData();
   %let TempSAS=%RanWinFile();
   proc contents data=&DSName out=&ContentsData noprint;
   run;
   filename SASfile "&TempSAS";
   data _null_;
      set &ContentsData end=lastobs;
      file SASfile;
      if (_N_=1) then do;
         if (TYPE=2) then
            put @4 "attrib " NAME "length=$" LENGTH 'label="' LABEL +(-1) '"';
         else
            put @4 "attrib " NAME "length=" LENGTH 'label="' LABEL +(-1) '"';
      end;
      else do;
         if (TYPE=2) then
            put @11 NAME "length=$" LENGTH 'label="' LABEL +(-1) '"';
         else
            put @11 NAME "length=" LENGTH 'label="' LABEL +(-1) '"';
      end;
      if (lastobs) then do;
         put @11 ';';
      end;
   run;
   data &OutDS;
      %include SASfile;
      set &DSName;
   run;
   %DeleteDS(&ContentsData);
%put DEBUG(ColumnSort): Temp File &TempSAS;
   filename SASfile clear;
   %EraseFile(&TempSAS);
%mend ColumnSort;
/*
%ColumnSort(DSName=AAEM.PVA97NK,OutDS=work.temp);
*/

/*--------------------------------------------------------*/
/*----  Generate data step code that would reproduce  ----*/
/*----  characteristics of input data, except with    ----*/
/*----  variables in column order also in order of    ----*/
/*----  variables as they appear in VarList.          ----*/
/*--------------------------------------------------------*/

%macro ColumnOrder(DSName=,OutDS=,VarList=);
   %local ContentsData SortData TempSAS NumVars;
   %let ContentsData=%RandWorkData();
   %let SortData=&ContentsData.S;
   %let TempSAS=%RanWinFile();
   %let NumVars=%NumInList(&VarList);
   proc contents data=&DSName out=&ContentsData noprint;
   run;
   data &ContentsData;
      set &ContentsData;
      SortOrder=VARNUM+&NumVars;
      keep NAME TYPE LENGTH LABEL VARNUM SortOrder;
   run;
   data &SortData;
      attrib NAME length=$32;
      do SortOrder=1 to &NumVars;
         NAME=strip(scan("&VarList",SortOrder));
         output;
      end;
      keep NAME SortOrder;
   run;
   proc sort data=&SortData;
      by NAME;
   run;
   proc sort data=&ContentsData;
      by NAME;
   run;
   data &ContentsData;
      merge &ContentsData &SortData;
      by NAME;
   run;
   proc sort data=&ContentsData;
      by SortOrder;
   run;
/*
proc print data=&ContentsData;
run;
 */
   filename SASfile "&TempSAS";
   data _null_;
      set &ContentsData end=lastobs;
      file SASfile;
      if (_N_=1) then do;
         if (TYPE=2) then
            put @4 "attrib " NAME "length=$" LENGTH 'label="' LABEL +(-1) '"';
         else
            put @4 "attrib " NAME "length=" LENGTH 'label="' LABEL +(-1) '"';
      end;
      else do;
         if (TYPE=2) then
            put @11 NAME "length=$" LENGTH 'label="' LABEL +(-1) '"';
         else
            put @11 NAME "length=" LENGTH 'label="' LABEL +(-1) '"';
      end;
      if (lastobs) then do;
         put @11 ';';
      end;
   run;
   data &OutDS;
      %include SASfile;
      set &DSName;
   run;
   %DeleteDS(&ContentsData);
   %DeleteDS(&SortData);
%put DEBUG(ColumnOrder): Temp File &TempSAS;
   filename SASfile clear;
   %EraseFile(&TempSAS);
%mend ColumnOrder;
/*
%ColumnOrder(DSName=AAEM.PVA97NK,OutDS=work.temp,VarList=ID TargetB TargetD DemAGe);
*/

/*----  Given pathname, get filename (MS Windows)  ----*/
%macro FileFromPath(PathName,FileName);
   &FileName=strip(reverse(substr(reverse(strip(&PathName)),1,index(reverse(strip(&PathName)),'/')-1)));
%mend FileFromPath;
/*
data _null_;
   length PN FN $ 32;
   PN="/abc/def/ghi.html";
   %FileFromPath(PN,FN);
   put FN=;
run;
*/

/*----  Given pathname, get filename (MS Windows)  ----*/
%macro FileFromPathWin(PathName,FileName);
   &FileName=strip(reverse(substr(reverse(strip(&PathName)),1,index(reverse(strip(&PathName)),'\')-1)));
%mend FileFromPathWin;
/*
data _null_;
   length PN FN $ 32;
   PN="C:\abc\def\ghi.txt";
   %FileFromPathWin(PN,FN);
   put FN=;
run;
*/

/*----  Find Content in SAS program files  ----*/

%macro FindStringSAS(FolderName=,String=,OutDS=);
   %local TempData HoldData NOBS;
   %let TempData=%RandWorkData();
   %let HoldData=&TempData.H;

   %if %sysfunc(exist(&OutDS)) %then %do;
      %put ERROR: In macro FindStringSAS, &OutDS already exists.;
   %end;
   %else %if (%ExistDirectory(Path=&FolderName) eq 0) %then %do;
      %put ERROR: In macro FindStringSAS, path &FolderName not found.;
   %end;
   %else %do;
  

   %WriteDirDS(&FolderName,&TempData);

   data &TempData;
      set &TempData;
      drop Kindex;
      Kindex=index(lowcase(FILENAME),".sas");
      if (Kindex>0) then do;
         if (substr(lowcase(FILENAME),Kindex)=".sas") then output;
      end;
   run;

   %let NOBS=%GetNumObs(&TempData);

   %do index=1 %to &NOBS;
      data _null_;
         set &TempData(firstobs=&index obs=&index);
         call symput("ThisFile",FILENAME);
      run;

      filename inpfile "%sysfunc(strip(&FolderName))\%sysfunc(strip(&ThisFile))";
      data &HoldData;
         attrib FilePath length=$128
                MatchLine length=$128;
       * retain NumLines 0;
         keep FilePath MatchLine;
         retain FilePath "%sysfunc(strip(&FolderName))\%sysfunc(strip(&ThisFile))";
         infile inpfile end=lastobs;
         input;
         MatchLine=_infile_;
         if (index(lowcase(MatchLine),lowcase("&String"))>0) then do;
         *  put "%sysfunc(strip(&ThisFile)):" MatchLine;
            output;
         *  NumLines+1;
         end;
         /*
         if (lastobs) and (NumLines>0) then do;
            put "%sysfunc(strip(&ThisFile)):" NumLines "matching lines found.";
         end;
         */
      run;
      proc append base=&OutDS data=&HoldData;
      run;
   %end;

   %DeleteDS(&TempData);
   %DeleteDS(&HoldData);

   %end;

%mend FindStringSAS;

/*

%FindStringSAS(FolderName=E:\SAS_Education,String=pipe,OutDS=work.temp);

%FindStringSAS(FolderName=E:\SAS_Education\mac1,String=varscope,OutDS=work.temp);


*/
%macro FindStringSASsub(FolderName=,String=,OutDS=);
   %local TempData HoldData NOBS;
   %let TempData=%RandWorkData();
   %let HoldData=&TempData.H;

   %if %sysfunc(exist(&OutDS)) %then %do;
      %put ERROR: In macro FindStringSAS, &OutDS already exists.;
   %end;
   %else %if (%ExistDirectory(Path=&FolderName) eq 0) %then %do;
      %put ERROR: In macro FindStringSAS, path &FolderName not found.;
   %end;
   %else %do;
  

   %WriteDirDSsub(&FolderName,&TempData);

   data &TempData;
      set &TempData;
      drop Kindex;
      Kindex=index(lowcase(FILENAME),".sas");
      if (Kindex>0) then do;
         if (substr(lowcase(FILENAME),Kindex)=".sas") then output;
      end;
   run;

   %let NOBS=%GetNumObs(&TempData);

   %do index=1 %to &NOBS;
      data _null_;
         set &TempData(firstobs=&index obs=&index);
         call symput("ThisFile",FILENAME);
      run;

      filename inpfile "%sysfunc(strip(&ThisFile))";
      data &HoldData;
         attrib FilePath length=$128
                MatchLine length=$128;
       * retain NumLines 0;
         keep FilePath MatchLine;
         retain FilePath "%sysfunc(strip(&ThisFile))";
         infile inpfile end=lastobs;
         input;
         MatchLine=_infile_;
         if (index(lowcase(MatchLine),lowcase("&String"))>0) then do;
         *  put "%sysfunc(strip(&ThisFile)):" MatchLine;
            output;
         *  NumLines+1;
         end;
         /*
         if (lastobs) and (NumLines>0) then do;
            put "%sysfunc(strip(&ThisFile)):" NumLines "matching lines found.";
         end;
         */
      run;
      proc append base=&OutDS data=&HoldData;
      run;
   %end;

   %DeleteDS(&TempData);
   %DeleteDS(&HoldData);

   %end;

%mend FindStringSASsub;

%macro FindStringSASsub(FolderName=,String=,OutDS=);
   %local TempData HoldData NOBS;
   %let TempData=%RandWorkData();
   %let HoldData=&TempData.H;

   %WriteDirDSsub(&FolderName,&TempData);

   data &TempData;
      set &TempData;
      drop Kindex;
      Kindex=index(lowcase(FILENAME),".sas");
      if (Kindex>0) then do;
         if (substr(lowcase(FILENAME),Kindex)=".sas") then output;
      end;
   run;

   %let NOBS=%GetNumObs(&TempData);

   %do index=1 %to &NOBS;
      data _null_;
         set &TempData(firstobs=&index obs=&index);
         call symput("ThisFile",FILENAME);
      run;

      filename inpfile "%sysfunc(strip(&ThisFile))";
      data &HoldData;
         attrib FilePath length=$128
                MatchLine length=$128;
       * retain NumLines 0;
         keep FilePath MatchLine;
         retain FilePath "%sysfunc(strip(&ThisFile))";
         infile inpfile end=lastobs;
         input;
         MatchLine=_infile_;
         if (index(lowcase(MatchLine),lowcase("&String"))>0) then do;
            put "%sysfunc(strip(&ThisFile)):" MatchLine;
            output;
         *  NumLines+1;
         end;
         /*
         if (lastobs) and (NumLines>0) then do;
            put "%sysfunc(strip(&ThisFile)):" NumLines "matching lines found.";
         end;
         */
      run;
      proc append base=&OutDS data=&HoldData;
      run;
   %end;

   %DeleteDS(&TempData);
   %DeleteDS(&HoldData);

%mend FindStringSASsub;

/*

%FindStringSASsub(FolderName=E:\SAS_Education\mac2,
                  String=badtype,OutDS=work.temp2);

*/

/*---------------------------------------------------------------------*/
/*----  Get random data set name for SAS dataset in WORK library.  ----*/
/*----  Example: %let TempName=%RandWorkData();                    ----*/
/*----  Assigning a random name rather than hardcoding a name      ----*/
/*----  like WORK.TEMP prevents overwriting an existing temporary  ----*/
/*----  data set. For example, suppose your have a program that    ----*/
/*----  creates WORK.TEMP, then calls a macro to perform some      ----*/
/*----  calculations. If the macro also creates WORK.TEMP, then    ----*/
/*----  the macro data set will overwrite your original temporary  ----*/
/*----  dataset. You may not be aware of this and will either      ----*/
/*----  accept bad numbers or have trouble debugging your code.    ----*/
/*---------------------------------------------------------------------*/
%macro RandWorkData();
   work.r%sysfunc(round(10000000*%sysfunc(ranuni(0))))
%mend RandWorkData;

/*-----------------------------------------------------------*/
/*----  Get random variable name of the form v1234567,   ----*/
/*----  that is, 'v' followed by seven (7) digits.       ----*/
/*----  Example: %let TempVar=%RandVarName();            ----*/
/*----           ...                                     ----*/
/*----           data &TempName;                         ----*/
/*----              set WORK.TEMP;                       ----*/
/*----              &TempVar=INTERCEPT+SLOPE*TIME;       ----*/
/*----              ...                                  ----*/
/*----              drop &TempVar;                       ----*/
/*----              ...                                  ----*/
/*----  Useful for generic macros that create temporary  ----*/
/*----  variables and must ensure that names of the      ----*/
/*----  temporary variables do not match existing        ----*/
/*----  variables in the dataset.                        ----*/
/*-----------------------------------------------------------*/
%macro RandVarName();
   v%sysfunc(round(10000000*%sysfunc(ranuni(0))))
%mend RandVarName;

%macro RandSASName();
   S%sysfunc(round(10000000*%sysfunc(ranuni(0))))
%mend RandSASName;

/*------------------------------------------------------*/
/*----  Random SAS Source File Name under windows   ----*/
/*----  Example: %let TempSAS=%RanWinFile();        ----*/
/*----  Format: C:\temp\f12345678.sas               ----*/
/*----          The 8 digits are randomly assigned. ----*/
/*----  Warnings: if folder C:\temp does not exist, ----*/
/*----  an error will result.                       ----*/
/*------------------------------------------------------*/
%macro RanWinFile(Suffix=NONE);
   %if ("&Suffix" eq "NONE") %then %do;
      C:\temp\f%sysfunc(round(100000000*%sysfunc(ranuni(0)))).sas
   %end;
   %else %do;
      C:\temp\f%sysfunc(round(100000000*%sysfunc(ranuni(0)))).&Suffix
   %end;
%mend RanWinFile;

%macro RanWorkFile();
   C:\temp\f%sysfunc(round(100000000*%sysfunc(ranuni(0)))).sas
%mend RanWorkFile;

%macro RanProjectFile();
   %if ("&PROJSASDIR" ne "") %then %do;
      &PROJSASDIR\f%sysfunc(round(100000000*%sysfunc(ranuni(0)))).sas
   %end;
   %else %do;
      C:\temp\f%sysfunc(round(100000000*%sysfunc(ranuni(0)))).sas
   %end;
%mend RanProjectFile;

/*----  Following written by Jim Georges  ----*/
%macro nlist(list);
   %let i=0;
   %do %while("%scan(&list,%eval(&i+1))" ne "");
      %let i=%eval(&i+1);
   %end;
   &i
%mend nlist;
%macro nlistspace(list);
   %let i=0;
   %do %while("%scan(&list,%eval(&i+1),%str( ))" ne "");
      %let i=%eval(&i+1);
   %end;
   &i
%mend nlistspace;

%macro CompressSASdata(DSName);
   data &DSName(compress=Y);
      set &DSName;
   run;
%mend CompressSASdata;


%put FileUtilities.sas Loaded;

/*--------------------------*/
/*----  End of program  ----*/
/*--------------------------*/

/*----------------------------------------------------*\
 |                                                    |
 |   Copyright (c) 2011 SAS Institute, Inc.           |
 |   Cary, N.C. USA 27513-8000                        |
 |   all rights reserved                              |
 |                                                    |
 |   THIS PROGRAM IS PROVIDED BY THE INSTITUTE "AS IS"|
 |   WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR|
 |   IMPLIED, INCLUDING BUT NOT LIMITED TO THE        |
 |   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS|
 |   FOR A PARTICULAR PURPOSE.  RECIPIENTS ACKNOWLEDGE|
 |   AND AGREE THAT THE INSTITUTE SHALL NOT BE LIABLE |
 |   WHATSOEVER FOR ANY DAMAGES ARISING OUT OF THEIR  |
 |   USE OF THIS PROGRAM.                             |
 |                                                    |
\*----------------------------------------------------*/
/*----------------------------------------------------*\
 |              S A S    T R A I N I N G              |
 |                                                    |
 |    NAME: ForecastUtilityMacros.sas                 |
 | PURPOSE: Macros for Time Series Analysis and       |
 |          Forecasting                               |
 |  SYSTEM: ALL (Windows pathname)                    |
 |    KEYS:                                           |
 |  COURSE: All                                       |
 |    DATA: None                                      |
 |                                                    |
 | SUPPORT: TJW                    UPDATE: 21JUN2011  |
 |     REF:                                           |
 |    MISC:                                           |
 |                                                    |
 |----------------------------------------------------|
 |   NOTES                                            |
 |                                                    |
 |   These macros were created to support SAS         |
 |   training. Macros can be incoprorated into SAS    |
 |   programs in several ways. For training purposes, |
 |   the macros are typically compiled as part of     |
 |   initialization code designed for the training.   |
 |   The usual strategy is for the course with code   |
 |   FXYZ to have an associated SAS file FXYZ.sas     |
 |   that includes the statement:                     |
 |                                                    |
 |   %include "<folder>/ForecastUtilityMacros.sas";   |
 |                                                    |
 |   where <folder> is the location of course SAS     |
 |   programs.                                        |
 |                                                    |
 |   Other strategies for macro compiling, storage,   |
 |   and access are possible.                         |
 |----------------------------------------------------|
 |   When a macro needs to create a temporary         |
 |   dataset, the macro %RandWorkData is called to    |
 |   supply a name created based on a uniform random  |
 |   number. The name is unlikely to conflict with    |
 |   existing temporary datasets. This practice       |
 |   prevents overwriting temporary datasets that     |
 |   have already been created by the calling program.|
 |                                                    |
\*----------------------------------------------------*/

/*---------------------------------------------------*\
  ---------------------------------------------------
  ---------------------------------------------------
  ----  Forecast file format conversion section  ----
  ---------------------------------------------------
  ---------------------------------------------------
\*---------------------------------------------------*/

/*-----------------------------------------*\
 |  Macro: ILeave2Composite                |
 +-----------------------------------------+
 |  Convert PROC FORECAST overlay type     |
 |  data (interleaved) to data with one    |
 |  record per unique date (composite).    |
 |  The data is converted in place. Only   |
 |  FORECAST, ACTUAL, and DATE are kept.   |
\*-----------------------------------------*/
%macro ILeave2Composite(DSName,TargetVar,DateVar);
%if %sysfunc(exist(&DSName)) %then %do;
   %if ("%GetVarType(&DSName,&TargetVar)" eq "N") %then %do;
      data &DSName;
         set &DSName;
         by &DateVar;
         retain Forecast Actual .;
         if (first.&DateVar) then do;
            Forecast=.;
            Actual=.;
         end; 
         if (upcase(_TYPE_)='FORECAST') then Forecast=&TargetVar;
         else if (upcase(_TYPE_)='ACTUAL') then Actual=&TargetVar;
         if (last.&DateVar) then output;
         keep Forecast Actual &DateVar;
      run;
   %end;
   %else %if ("%GetVarType(&DSName,&TargetVar)" eq "C") %then %do;
      %put ERROR: In Macro ILeave2Composite, variable &TargetVar is not numeric.;
   %end;
   %else %do;
      %put ERROR: In Macro ILeave2Composite, variable &TargetVar is not in &DSName.;
   %end;
%end;
%else %do;
   %put ERROR: In macro ILeave2Composite, cannot open &DSName;
%end;
%mend ILeave2Composite;

/*-----------------------------------------*\
 |  Macro: ILeave2CompositeAll             |
 +-----------------------------------------+
 |  Like ILeave2Composite, except all      |
 |  variables are written to the new       |
 |  data set, including Residual, L95,     |
 |  U95, STD.                              |
\*-----------------------------------------*/
%macro ILeave2CompositeAll(DSName,TargetVar,DateVar);
%if %sysfunc(exist(&DSName)) %then %do;
   data &DSName;
      attrib &DateVar label="Date"
             Actual   length=8 label="&TargetVar"
             Forecast length=8 label="Forecast"
             Residual length=8 label="Residual"
             STD      length=8 label="Standard Error of Forecast"
             L95      length=8 label="Lower 95% Prediction Limit"
             U95      length=8 label="Upper 95% Prediction Limit";
      set &DSName;
      by &DateVar;
      retain Forecast Actual Residual L95 U95 STD .;
      if (first.&DateVar) then do;
         Forecast=.;
         Actual=.;
         Residual=.;
         L95=.;
         U95=.;
         STD=.;
      end; 
      if (upcase(_TYPE_)='FORECAST') then Forecast=&TargetVar;
      else if (upcase(_TYPE_)='ACTUAL') then Actual=&TargetVar;
      else if (upcase(_TYPE_)='RESIDUAL') then Residual=&TargetVar;
      else if (upcase(_TYPE_)='L95') then L95=&TargetVar;
      else if (upcase(_TYPE_)='U95') then U95=&TargetVar;
      else if (upcase(_TYPE_)='STD') then STD=&TargetVar;
      if (last.&DateVar) then output;
      keep &DateVar Forecast Actual Residual STD L95 U95;
   run;
%end;
%else %do;
   %put ERROR: In macro ILeave2CompositeAll, cannot open &DSName;
%end;
%mend ILeave2CompositeAll;

/*-----------------------------------------*\
 |  Macro: ModifyESM                       |
 +-----------------------------------------+
 |  Convert PROC ESM forecast data set     |
 |  to be consistent with others.          |
 |  WARNING: Assumes single time series    |
\*-----------------------------------------*/
%macro ModifyESM(DSName=);
%if %sysfunc(exist(&DSName)) %then %do;
   data _NULL_;
      set &DSName(obs=1);
      call symput("TargetVar",_NAME_);
   run;
   data &DSName;
      set &DSName;
      label ACTUAL="&TargetVar"
            ERROR="Residual";
      drop _NAME_;
      rename PREDICT=Forecast
             ACTUAL=&TargetVar
             ERROR=Residual
             LOWER=L95
             UPPER=U95;
   run;
%end;
%else %do;
   %put ERROR: In macro ModifyESM, cannot open &DSName;
%end;
%mend ModifyESM;

/*-------------------------------------------------*\
 |  Macro: ByToColumn                              |
 +-------------------------------------------------+
 |  Convert BY group data to multiple column data  |
 |  This macro assumes data has columns:           |
 |  DateVar ByVar1 ByVar2 ... ByVarN ValueVar      |
 |  Any additional variables will be transposed    |
 |  and may become meaningless.                    |
 |  WARNING: There is no effort to ensure that     |
 |  the created BY variable has sufficient length, |
 |  nor is there any checking to ensure the names  |
 |  created using the BY variable will be valid    |
 |  SAS variable names. PROC TRANSPOSE helps.      |
\*-------------------------------------------------*/
%macro ByToColumn(DSName,ByVars,ValueVar,DateVar,Prefix);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempVar=%RandVarName();
   data &DSName;
      set &DSName;
      %ConcatVars(&ByVars,&TempVar);
      drop &ByVars;
   run;
   proc sort data=&DSName;
      by &DateVar &TempVar;
   run;
   proc transpose data=&DSName 
                  out=&DSName(drop=_NAME_ _LABEL_)
                  prefix=&Prefix;
      id &TempVar;
      var &ValueVar;
      by &DateVar;
   run;
%end;
%else %do;
   %put ERROR: In macro ByToColumn, cannot open &DSName;
%end;
%mend ByToColumn;


/*----------------------------------------------*\
 |  Macro: ColumnToBy                           |
 +----------------------------------------------+
 |  Transpose data with time series in columns  |
 |  to data with time series as BY variables.   |
 |  This macro assumes the data has columns:    |
 |  DateVar Column1 Column2 ... ColumnN         |
 |  where ColumnK is the name of Column K. Any  |
 |  variables not named in the ColumnNames      |
 |  string will be deleted (dropped).           |
\*----------------------------------------------*/
%macro ColumnToBy(DSName,ColumnNames,ByName,DateVar,NewColumn);
%if %sysfunc(exist(&DSName)) %then %do;
   data &DSName;
      set &DSName;
      keep &ColumnNames &DateVar;
   run;
   proc sort data=&DSName;
      by &DateVar;
   run;
   proc transpose data=&DSName out=&DSName
                  name=&ByName
                  prefix=Value
                  ;
      by &DateVar;
      var &ColumnNames;
   run;
   data &DSName;
      set &DSName;
      if (Value1=.) then delete;
      rename Value1=&NewColumn;
      label &DateVar="Date"
            &ByName ="&ByName"
            Value1  ="&NewColumn";
   run;
   proc sort data=&DSName;
      by &ByName &DateVar;
   run;
%end;
%else %do;
   %put ERROR: In macro ColumnToBy, cannot open &DSName;
%end;
%mend ColumnToBy;


/*---------------------------------------------*\
 |  Macro: MakeOverlay                         |
 +---------------------------------------------+
 |  Prepare interleaved forecast data so that  |
 |  observations of _TYPE_='FORECAST' are      |
 |  deleted when _LEAD_=0, so that only future |
 |  forecasts are kept (and one-step ahead     |
 |  forecasts deleted).                        |
\*---------------------------------------------*/
%macro MakeOverlay(DSName,TargetVar,DateVar);
%if %sysfunc(exist(&DSName)) %then %do;
   data &DSName;
      set &DSName;
      if (upcase(_TYPE_)='FORECAST') and (_LEAD_=0) then delete;
      else if (upcase(_TYPE_) in ('FORECAST','ACTUAL')) then output;
      keep &TargetVar _TYPE_ _LEAD_ &DateVar;
      rename _TYPE_=Type 
             _LEAD_=Lead;
   run;
   proc sort data=&DSName;
      by Type &DateVar;
   run;
%end;
%else %do;
   %put ERROR: In macro MakeOverlay, cannot open &DSName;
%end;
%mend MakeOverlay;



/*-------------------------------------------------------*\
  -------------------------------------------------------
  -------------------------------------------------------
  ----  Modify and/or augment original data section  ----
  -------------------------------------------------------
  -------------------------------------------------------
\*-------------------------------------------------------*/

/*---------------------------------------------*\
 |  Macro: PrepareAppend                       |
 +---------------------------------------------+
 |  Utility macro used by macro EventAnalysis  |
 |  to prepare event estimation data and       |
 |  append to a master data set whose purpose  |
 |  is to use SBC to try to identify an        |
 |  appropriate event model.                   |
\*---------------------------------------------*/
%macro PrepareAppend(ModelName);
   data &TempEach;
      set &TempEach;
      attrib ModelName length=$40 label="Model Name"
             SBC       length=8 label="Schwarz Bayesion Criterion";
      if (_STAT_='SBC') then do;
         ModelName="&ModelName";
         SBC=_VALUE_;
         output;
      end;
      keep ModelName SBC;
   run;
   proc append base=&TempAll data=&TempEach;
   run;
%mend PrepareAppend;

/*------------------------------------------------*\
 |  Macro: EventVariables                         |
 +------------------------------------------------+
 |  Add Pulse, Step, and Ramp variables and a     |
 |  Time Index variable to the input SAS dataset. |
 |  dataset.                                      |
 +------------------------------------------------+
 |  NOTE: Since an exact equality comparison is   |
 |        made for the event date, you must be    |
 |        aware of how the date variable is       |
 |        defined. For example, monthly date      |
 |        values may be defined to be the first   |
 |        day of the month. Thus, even if the     |
 |        actual event occurs later in the month, |
 |        you must specify the first day of the   |
 |        month as the event date.                |
 +------------------------------------------------+
 |  Example                                       |
 |                                                |
 |  data MyLib.MyNewData;                         |
 |     set MyLib.MyOldData;                       |
 |     %EventVariables(Date,'01JUL1982'd);        |
 |  run;                                          |
\*------------------------------------------------*/
%macro EventVariables(DateVar,IntDate);
   attrib Pulse     length=3 label='Pulse Function'
          Step      length=3 label='Step Function'
          Ramp      length=3 label='Ramp Function'
          Time      length=8 label='Time Index';
   retain Pulse Step Ramp Time 0;
   Time+1;
   if (&DateVar = &IntDate) then do;
      Ramp+1;
      Step=1;
      Pulse=1;
   end;
   else if (&DateVar > &IntDate) then do;
      Ramp+1;
      Pulse=0;
   end;
%mend EventVariables;

/*------------------------------------------------*\
 |  Macro: EventAnalysis                          |
 +------------------------------------------------+
 |  Multi-faceted event analysis macro.           |
 |                                                |
 |  Step 1: Add Pulse, Step, and Ramp variables   |
 |  and a Time Index variable to the input SAS    |
 |  dataset.                                      |
 |                                                |
 |  Step 2: Try seven interventions               |
 |     1. Abrupt Temporary: Pulse                 |
 |     2. Abrupt Temporary: Pulse with            |
 |        exponential decay                       |
 |     3. Abrupt Temporary: Pulse with oscilating |
 |        decay                                   |
 |     4. Abrupt Permanent: Step                  |
 |     5. Gradual Permanent: Gradual Step         |
 |        asymptoting to new level                |
 |     6. Gradual Permanent: Gradual Step         |
 |        oscilating to new level                 |
 |     7. Change in level and slope               |
 |                                                |
 |  Step 3: Print results sorted by SBC           |
 +------------------------------------------------+
 |  NOTE: Since no additional variables and no    |
 |        ARMA(p,q) component is supported, this  |
 |        macro has limited usefulness, but may   |
 |        serve as a foundation for building a    |
 |        custom macro for specific intervention  |
 |        problems.                               |
\*------------------------------------------------*/
%macro EventAnalysis(DSName,TargetVar,DateVar,IntDate,
                     ARList=0,MAList=0,DifList=0,
                     PrintAll=NO);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempAll=%RandWorkData();
   %let TempEach=&TempAll.Each;
   %let TempDSName=&TempAll.IN;
   data &TempDSName;
      set &DSName;
      attrib Pulse     length=3 label='Pulse Function'
             Step      length=3 label='Step Function'
             Ramp      length=3 label='Ramp Function'
             TimeIndex length=8 label='Time Index';
      retain Pulse Step Ramp TimeIndex 0;
      TimeIndex+1;
      if (&DateVar = &IntDate) then do;
         Ramp+1;
         Step=1;
         Pulse=1;
      end;
      else if (&DateVar > &IntDate) then do;
         Ramp+1;
         Pulse=0;
      end;
   run;
   /*----  Output full estimation results  ----*/
   %if ("%upcase(&PrintAll)" eq "YES") %then %do;
      proc arima data=&TempDSName;
         identify var=&TargetVar(&DifList)
                  crosscor=(Pulse Step Ramp TimeIndex)
                  minic scan esacf
                  nlags=13;
         /*---- Abrupt Temporary: Pulse  ----*/
         estimate input=(    Pulse) method=ml;
         /*---- Abrupt Temporary:             ----*/
         /*---- Pulse with exponential decay  ----*/
         estimate input=(/(1)Pulse) method=ml;
         /*---- Abrupt Temporary:             ----*/
         /*---- Pulse with oscillating decay  ----*/
         estimate input=(/(1 2)Pulse) method=ml;
         /*---- Abrupt Permanent: Step  ----*/
         estimate input=(    Step) method=ml;
         /*---- Gradual Permanent:                     ----*/
         /*---- Gradual Step asymptoting to new level  ----*/
         estimate input=(/(1)Step) method=ml;
         /*---- Gradual Permanent:                     ----*/
         /*---- Gradual Step oscillating to new level  ----*/
         estimate input=(/(1 2)Step) method=ml;
         /*---- Change in  slope  ----*/
         estimate input=(TimeIndex Ramp) method=ml;
         /*---- Change in level and slope  ----*/
         estimate input=(Step Ramp) method=ml;
         /*---- Change in level and slope  ----*/
         estimate input=(TimeIndex Step Ramp) method=ml;
      run;
      quit;
   %end;
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Abrupt Temporary: Pulse  ----*/
      estimate P=&ARList Q=&MAList
               input=(    Pulse) method=ml outstat=&TempEach noprint;
   run;
   quit;
   %PrepareAppend(Abrupt Temporary);
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Abrupt Temporary:             ----*/
      /*---- Pulse with exponential decay  ----*/
      estimate P=&ARList Q=&MAList
               input=(/(1)Pulse) method=ml outstat=&TempEach noprint;
     
   run;
   quit;
   %PrepareAppend(Abrupt Temporary Decay);
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Abrupt Temporary:             ----*/
      /*---- Pulse with oscillating decay  ----*/
      estimate P=&ARList Q=&MAList
               input=(/(1 2)Pulse) method=ml outstat=&TempEach noprint;;
     
   run;
   quit;
   %PrepareAppend(Abrupt Temporary Oscillating);
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Abrupt Permanent: Step  ----*/
      estimate P=&ARList Q=&MAList
               input=(    Step) method=ml outstat=&TempEach noprint;
     
   run;
   quit;
   %PrepareAppend(Abrupt Permanent);
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Gradual Permanent:                     ----*/
      /*---- Gradual Step asymptoting to new level  ----*/
      estimate P=&ARList Q=&MAList
               input=(/(1)Step) method=ml outstat=&TempEach noprint;
     
   run;
   quit;
   %PrepareAppend(Gradual Permanent);
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Gradual Permanent:                     ----*/
      /*---- Gradual Step oscillating to new level  ----*/
      estimate P=&ARList Q=&MAList
               input=(/(1 2)Step) method=ml outstat=&TempEach noprint;
     
   run;
   quit;
   %PrepareAppend(Gradual Permanent Oscillating);
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Change in slope  ----*/
      estimate P=&ARList Q=&MAList
               input=(TimeIndex Ramp) method=ml outstat=&TempEach noprint;
   run;
   quit;
   %PrepareAppend(Slope Change);
   proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Change in level and slope  ----*/
      estimate P=&ARList Q=&MAList
               input=(TimeIndex Step Ramp) method=ml outstat=&TempEach noprint;
   run;
   quit;
   %PrepareAppend(Level/Slope Change);
      proc arima data=&TempDSName;
      identify var=&TargetVar(&DifList)
               crosscor=(Pulse Step Ramp TimeIndex)
               nlags=13 noprint;
      /*---- Change in level and slope  ----*/
      estimate P=&ARList Q=&MAList
               input=(Step Ramp) method=ml outstat=&TempEach noprint;
   run;
   quit;
   %PrepareAppend(Step/Ramp Change);
   proc sort data=&TempAll;
      by SBC;
   run;
   proc print data=&TempAll;
      var ModelName SBC;
   run;
   %DeleteDS(&TempAll);
   %DeleteDS(&TempEach);
   %DeleteDS(&TempDSName);
%end;
%else %do;
   %put ERROR: In macro EventAnalysis, cannot open &DSName;
%end;
%mend EventAnalysis;

/*---------------------------------------------*\
 |  Macro: MLMINIC                             |
 +---------------------------------------------+
 |  Pick best ARMA model based on SBC or AIC.  |
 +---------------------------------------------+
 |  Arguments                                  |
 |  DSName      Data set name                  |
 |  TargetVar   Target variable name           |
 |  ARlist      n|n1 n2 n3 n4...nk             |
 |  MAlist      n|n1 n2 n3 n4...nk             |
 |  DifList=    n1 n2...                       |
 |  OutData=    Output data set                |
 +---------------------------------------------+
 |  If ARlist and MAlist are single integers,  |
 |  try all orders of p up to ARlist and all   |
 |  orders of q up to MAlist. If ARlist and    |
 |  MAlist are lists of integers, then the     |
 |  lists must have the same number of         |
 |  integers, and the integers are paired to   |
 |  get p and q. For example, ARlist=0 2 3,    |
 |  MAlist=1 4 5, cause the following models   |
 |  to be fit: (p,q)=(0,1) (2,4) (3,5).        |
\*---------------------------------------------*/
%macro MLMINIC(DSName,TargetVar,ARlist,MAlist,DifList=,OutData=);
%if %sysfunc(exist(&DSName)) %then %do;
   /*----  Set up temporary Data  ----*/
   %let Tempstat=%RandWorkData();
   %let TempAll=&Tempstat.ALL;
   %let NumAR=%nlistspace(&ARlist);
   %let NumMA=%nlistspace(&MAlist);
   %if (&DifList eq) %then %do;
      %let DifList=0;
   %end;
   %if (&NumAR eq &NumMA) %then %do;
      data &TempAll;
         P=.;
         Q=.;
         SBC=.;
         AIC=.;
         output;
      run;
   %end;
   %if (&NumAR eq 1) and (&NumMA eq 1) %then %do;
      %let MAXP=&ARlist;
      %let MAXQ=&MAlist;
      %let MaxLags=%eval(&MAXP+&MAXQ+3);

      %do ARorder=0 %to &MAXP;
         %do MAorder=0 %to &MAXQ;
            proc arima data=&DSName;
               identify var=&TargetVar(&DifList) NLAGS=&MaxLags noprint;
               estimate p=&ARorder q=&MAorder method=ml noprint
               outstat=&Tempstat maxiter=500;
            run;
            quit;
            data &Tempstat;
               set &Tempstat;
               retain FOUND 0 AIC . SBC .;
               if (_STAT_='AIC') then do;
                  AIC=_VALUE_;
                  FOUND+1;
               end;
               if (_STAT_='SBC') then do;
                  SBC=_VALUE_;
                  FOUND+1;
               end;
               if (FOUND=2) then do;
                  P=&ARorder;
                  Q=&MAorder;
                  output;
                  stop;
               end;
               keep P Q AIC SBC;
            run;
            proc append base=&TempAll data=&Tempstat;
            run;
         %end;
      %end;
   %end;
   %else %if (&NumAR eq &NumMA) %then %do;
      %let MaxLags=0;
      %do index=1 %to &NumAR;
         %let ARMAsum=%eval(%scan(&ARlist,&index)+%scan(&MAlist,&index));
         %if (&MaxLags lt &ARMAsum) %then %do;
            %let MaxLags=&ARMAsum;
         %end;
      %end;
      %let MaxLags=%eval(&MaxLags + 3); 
      %do index=1 %to &NumAR;
            proc arima data=&DSName;
               identify var=&TargetVar(&DifList) NLAGS=&MaxLags noprint;
               estimate p=%scan(&ARlist,&index)
                        q=%scan(&MAlist,&index) method=ml noprint
                        outstat=&Tempstat maxiter=500;
            run;
            quit;
            data &Tempstat;
               set &Tempstat;
               retain FOUND 0 AIC . SBC .;
               if (_STAT_='AIC') then do;
                  AIC=_VALUE_;
                  FOUND+1;
               end;
               if (_STAT_='SBC') then do;
                  SBC=_VALUE_;
                  FOUND+1;
               end;
               if (FOUND=2) then do;
                  P=%scan(&ARlist,&index);
                  Q=%scan(&MAlist,&index);
                  output;
                  stop;
               end;
               keep P Q AIC SBC;
            run;
            proc append base=&TempAll data=&Tempstat;
            run;
      %end;
   %end;
   %if (&NumAR ne &NumMA) %then %do;
      %put ERROR: In macro MLMINIC, ARlist=&NumAR MAlist=&NumMA.;
   %end;
   %else %do;
      data &TempAll;
         set &TempAll;
         if (P=.) and (Q=.) then delete;
      run;
      data _null_;
         set &TempAll end=lastobs;
         retain SBCP SBCQ AICP AICQ 0 MinSBC . MinAIC .;
         if (MinAIC=.) and (AIC>.) then do;
            MinAIC=AIC;
            AICP=P;
            AICQ=Q;
         end;
         if (MinSBC=.) and (SBC>.) then do;
            MinSBC=SBC;
            SBCP=P;
            SBCQ=Q;
         end;
         if (MinAIC>AIC>.) then do;
            MinAIC=AIC;
            AICP=P;
            AICQ=Q;
         end;
         if (MinSBC>SBC>.) then do;
            MinSBC=SBC;
            SBCP=P;
            SBCQ=Q;
         end;
         if (lastobs) then do;
            call symput('BestAICP',put(AICP,z3.0));
            call symput('BestAICQ',put(AICQ,z3.0));
            call symput('BestSBCP',put(SBCP,z3.0));
            call symput('BestSBCQ',put(SBCQ,z3.0));
         end;
      run;

         data _null_;
            put "From Macro MLMINIC: &SYSDATE &SYSTIME";
            put "From Macro MLMINIC: Best AR order by AIC=&BestAICP";
            put "From Macro MLMINIC: Best MA order by AIC=&BestAICQ";
            put "From Macro MLMINIC: Best AR order by SBC=&BestSBCP";
            put "From Macro MLMINIC: Best MA order by SBC=&BestSBCQ";
         run;

      %if (&OutData ne) %then %do;
         data &OutData;
            set &TempAll;
         run;
      %end;
      %DeleteDS(&Tempstat);
      %DeleteDS(&TempAll);
   %end;
%end;
%else %do;
   %put ERROR: In macro MLMINIC, cannot open &DSName;
%end;
%mend MLMINIC;

/*----------------------------------------------*\
 |  Macro: AutoARMASort                         |
 +----------------------------------------------+
 |  Given a data set created by one of the      |
 |  AutoARMA macros, create a data set of       |
 |  model specs sorted by goodness-of-fit       |
 |  statistic. Top=5 by default.                |
\*----------------------------------------------*/
%macro AutoARMASort(DSName,Top=5,OutDS=);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempData=%RandWorkData();
   %let TempONE=&TempData.ONE;
   %let TempTWO=&TempData.TWO;
   proc contents data=&DSName out=&TempData noprint;
   run;
   data _null_;
      attrib NameOne length=$8 NameTwo length=$8;
      set &TempData end=lastobs;
      retain DidP DidQ DidOne DidTwo 0 NameOne ' ' NameTwo ' ';
      if (DidP=0) and (NAME='P') then DidP=1;
      else if (DidQ=0) and (NAME='Q') then DidQ=1;
      else if (DidOne=0) and (not (NAME in ('P','Q'))) then do;
         DidOne=1;
         NameOne=NAME;
      end;
      else if (DidTwo=0) and (not (NAME in ('P','Q'))) then do;
         DidTwo=1;
         NameTwo=NAME;
      end;
      if (lastobs) then do;
         if (sum(DidP, DidQ, DidOne, DidTwo)<4) then do;
            put "ERROR: Invalid data set in macro AutoARMASort.";
            call symput("GOF_ONE","BADBAD");
         end;
         else do;
            call symput("GOF_ONE",NameOne);
            call symput("GOF_TWO",NameTwo);
         end;
      end;
   run;
   %if ("&GOF_ONE" ne "BADBAD") %then %do;
      proc sort data=&DSName;
         by &GOF_ONE;
      run;

      data &TempONE;
         set &DSName(obs=&Top);
         P_&GOF_ONE=P;
         Q_&GOF_ONE=Q;
         keep P_&GOF_ONE Q_&GOF_ONE &GOF_ONE;
      run;

      proc sort data=&DSName;
         by &GOF_TWO;
      run;

      data &TempTWO;
         set &DSName(obs=&Top);
         P_&GOF_TWO=P;
         Q_&GOF_TWO=Q;
         keep P_&GOF_TWO Q_&GOF_TWO &GOF_TWO;
      run;
      %if ("&OutDS" ne "") %then %do;
         data &OutDS;
            merge &TempOne &TempTwo;
         run;
         %DeleteDS(&TempData);
         %DeleteDS(&TempONE);
         %DeleteDS(&TempTWO);
      %end;
      %else %do;
         data &TempData;
            merge &TempOne &TempTwo;
         run;
         proc print data=&TempData;
            var P_&GOF_ONE Q_&GOF_ONE &GOF_ONE 
                P_&GOF_TWO Q_&GOF_TWO &GOF_TWO;
         run;
         %DeleteDS(&TempData);
         %DeleteDS(&TempONE);
         %DeleteDS(&TempTWO);
      %end;
   %end;
   %else %do;
      %DeleteDS(&TempData);
   %end;
%end;
%else %do;
   %put ERROR: In macro AutoARMASort, cannot open &DSName;
%end;
%mend AutoARMASort;

/*---------------------------------------------*\
 |  Macro: AutoARMAHoldout                     |
 +---------------------------------------------+
 |  Pick best ARMA model based on RMSE or MAPE |
 |  using a holdout sample and one-step ahead  |
 |  forecasts.                                 |
 +---------------------------------------------+
 |  See macro AutoARMA for details.            |
\*---------------------------------------------*/
%macro AutoARMAHoldout(DSName,TargetVar,Holdout,
                       ARlist,MAlist,OutData=);
%local Tempfore TempAll TempInput HoldVar NumAR NumMA;
%if %sysfunc(exist(&DSName)) %then %do;
   %let Tempfore=%RandWorkData();
   %let TempAll=&Tempfore.ALL;
   %let TempInput=&Tempfore.INP;
   %let TempModel=&Tempfore.MOD;
   %let HoldVar=%RandVarName();
   %let NumAR=%nlistspace(&ARlist);
   %let NumMA=%nlistspace(&MAlist);
   %global MAPE RMSE;
   %if (&NumAR eq &NumMA) %then %do;
      data &TempAll;
         P=.;
         Q=.;
         MAPE=.;
         RMSE=.;
         output;
      run;
      %let Cutoff=%eval(%GetNumObs(&DSName) - &Holdout);
      data &TempInput;
         set &DSName;
         retain ObsNo 0;
         ObsNo+1;
         &HoldVar=&TargetVar;
         if (ObsNo>&Cutoff) then &HoldVar=.;
      run;
   %end;
   %if (&NumAR eq 1) and (&NumMA eq 1) %then %do;
      %let MAXP=&ARlist;
      %let MAXQ=&MAlist;
      %let MaxLags=%eval(&MAXP+&MAXQ+3);

      %do ARorder=0 %to &MAXP;
         %do MAorder=0 %to &MAXQ;
            proc arima data=&TempInput;
               identify var=&HoldVar NLAGS=&MaxLags noprint;
               estimate p=&ARorder q=&MAorder 
                        method=ml 
                        outmodel=&TempModel
                        noprint maxiter=500;
            run;
            quit;

            data &TempModel;
               attrib _NAME_ length=$32;
               set &TempModel(rename=(_NAME_=_NEWNAME_));
               if (_NEWNAME_="&HoldVar") then _NAME_="&TargetVar";
               else _NAME_=_NEWNAME_;
               drop _NEWNAME_;
            run;
            %ArimaNoest(DSName=&TempInput,DSModel=&TempModel,
                        OutFor=&Tempfore,Lead=0);

            data &Tempfore;
               set &Tempfore(firstobs=%eval(&Cutoff+1));
               keep &TargetVar FORECAST;
            run;

            %GetGOF(DSName=&Tempfore,ActualVar=&TargetVar,
                    ForeVar=FORECAST);
            data &TempAll;
               set &TempAll end=lastobs;
               output;
               if (lastobs) then do;
                  P=&ARorder;
                  Q=&MAorder;
                  RMSE=&RMSE;
                  MAPE=&MAPE;
                  output;
               end;
            run;
         %end;
      %end;
   %end;
   %else %if (&NumAR eq &NumMA) %then %do;
      %let MaxLags=0;
      %do index=1 %to &NumAR;
         %let ARMAsum=%eval(%scan(&ARlist,&index)+%scan(&MAlist,&index));
         %if (&MaxLags lt &ARMAsum) %then %do;
            %let MaxLags=&ARMAsum;
         %end;
      %end;
      %let MaxLags=%eval(&MaxLags + 3);
      %do index=1 %to &NumAR;

            proc arima data=&TempInput;
               identify var=&HoldVar NLAGS=&MaxLags noprint;
               estimate p=%scan(&ARlist,&index) 
                        q=%scan(&MAlist,&index) 
                        method=ml 
                        outmodel=&TempModel
                        noprint maxiter=500;
            run;
            quit;

            data &TempModel;
               attrib _NAME_ length=$32;
               set &TempModel(rename=(_NAME_=_NEWNAME_));
               if (_NEWNAME_="&HoldVar") then _NAME_="&TargetVar";
               else _NAME_=_NEWNAME_;
               drop _NEWNAME_;
            run;
            %ArimaNoest(DSName=&TempInput,DSModel=&TempModel,
                        OutFor=&Tempfore,Lead=0);

            data &Tempfore;
               set &Tempfore(firstobs=%eval(&Cutoff+1));
               keep &TargetVar FORECAST;
            run;

            %GetGOF(DSName=&Tempfore,ActualVar=&TargetVar,
                    ForeVar=FORECAST);
            data &TempAll;
               set &TempAll end=lastobs;
               output;
               if (lastobs) then do;
                  P=%scan(&ARlist,&index);
                  Q=%scan(&MAlist,&index);
                  RMSE=&RMSE;
                  MAPE=&MAPE;
                  output;
               end;
            run;
      %end;
   %end;
   %if (&NumAR ne &NumMA) %then %do;
      %put ERROR: In macro AutoARMA, ARlist=&NumAR MAlist=&NumMA.;
   %end;
   %else %do;
      data &TempAll;
         set &TempAll;
         if (P=.) and (Q=.) then delete;
      run;
      data _null_;
         set &TempAll end=lastobs;
         retain RMSEP RMSEQ MAPEP MAPEQ 0 MinRMSE . MinMAPE .;
         if (MinMAPE=.) and (MAPE>.) then do;
            MinMAPE=MAPE;
            MAPEP=P;
            MAPEQ=Q;
         end;
         if (MinRMSE=.) and (RMSE>.) then do;
            MinRMSE=RMSE;
            RMSEP=P;
            RMSEQ=Q;
         end;
         if (MinMAPE>MAPE>.) then do;
            MinMAPE=MAPE;
            MAPEP=P;
            MAPEQ=Q;
         end;
         if (MinRMSE>RMSE>.) then do;
            MinRMSE=RMSE;
            RMSEP=P;
            RMSEQ=Q;
         end;
         if (lastobs) then do;
            call symput('BestMAPEP',put(MAPEP,z3.0));
            call symput('BestMAPEQ',put(MAPEQ,z3.0));
            call symput('BestRMSEP',put(RMSEP,z3.0));
            call symput('BestRMSEQ',put(RMSEQ,z3.0));
         end;
      run;

         data _null_;
            put "From Macro AutoARMA: &SYSDATE &SYSTIME";
            put "From Macro AutoARMA: Best AR order by MAPE=&BestMAPEP";
            put "From Macro AutoARMA: Best MA order by MAPE=&BestMAPEQ";
            put "From Macro AutoARMA: Best AR order by RMSE=&BestRMSEP";
            put "From Macro AutoARMA: Best MA order by RMSE=&BestRMSEQ";
         run;

      %if (&OutData ne) %then %do;
         data &OutData;
            set &TempAll;
         run;
      %end;
      %DeleteDS(&Tempfore);
      %DeleteDS(&TempAll);
      %DeleteDS(&TempInput);
      %DeleteDS(&TempModel);
   %end;
%end;
%else %do;
   %put ERROR: In macro AutoARMAHoldout, cannot open &DSName;
%end;
%mend AutoARMAHoldout;

/*---------------------------------------------*\
 |  Macro: AutoARMAHOmulti                     |
 +---------------------------------------------+
 |  Pick best ARMA model based on RMSE or MAPE |
 |  using a holdout sample and multi-step      |
 |  ahead forecasts.                           |
 +---------------------------------------------+
 |  WARNING: For stationary models, forecasts  |
 |  converge to the mean. Higher order models  |
 |  typically produce forecasts that converge  |
 |  more slowly to the mean, so higher order   |
 |  models might produce forecasts that appear |
 |  to be more accurate. Judging stationary    |
 |  models on many-step ahead forecasts is not |
 |  prudent.                                   |
 +---------------------------------------------+
 |  See macro AutoARMA for details.            |
\*---------------------------------------------*/
%macro AutoARMAHOmulti(DSName,TargetVar,Holdout,
                       ARlist,MAlist,OutData=);
%if %sysfunc(exist(&DSName)) %then %do;
   /*----  Set up temporary Data  ----*/
   %let Tempfore=%RandWorkData();
   %let TempAll=&Tempfore.ALL;
   %let TempInput=&Tempfore.INP;
   %let HoldVar=%RandVarName();
   %let NumAR=%nlistspace(&ARlist);
   %let NumMA=%nlistspace(&MAlist);
   %global MAPE RMSE;
   %if (&NumAR eq &NumMA) %then %do;
      data &TempAll;
         P=.;
         Q=.;
         MAPE=.;
         RMSE=.;
         output;
      run;
      %let Cutoff=%eval(%GetNumObs(&DSName) - &Holdout);
      data &TempInput;
         set &DSName;
         retain ObsNo 0;
         ObsNo+1;
         &HoldVar=&TargetVar;
         if (ObsNo>&Cutoff) then &HoldVar=.;
      run;
   %end;
   %if (&NumAR eq 1) and (&NumMA eq 1) %then %do;
      %let MAXP=&ARlist;
      %let MAXQ=&MAlist;
      %let MaxLags=%eval(&MAXP+&MAXQ+3);

      %do ARorder=0 %to &MAXP;
         %do MAorder=0 %to &MAXQ;
            proc arima data=&TempInput;
               identify var=&HoldVar NLAGS=&MaxLags noprint;
               estimate p=&ARorder q=&MAorder 
                        method=ml noprint maxiter=500;
               forecast lead=&Holdout out=&Tempfore noprint;
            run;
            quit;
            data &Tempfore;
               merge &Tempfore &DSName;
               keep &TargetVar &HoldVar FORECAST;
            run;
            data &Tempfore;
               set &Tempfore(where=(&HoldVar=.));
            run;
            %GetGOF(DSName=&Tempfore,ActualVar=&TargetVar,
                    ForeVar=FORECAST);
            data &TempAll;
               set &TempAll end=lastobs;
               output;
               if (lastobs) then do;
                  P=&ARorder;
                  Q=&MAorder;
                  RMSE=&RMSE;
                  MAPE=&MAPE;
                  output;
               end;
            run;
         %end;
      %end;
   %end;
   %else %if (&NumAR eq &NumMA) %then %do;
      %let MaxLags=0;
      %do index=1 %to &NumAR;
         %let ARMAsum=%eval(%scan(&ARlist,&index)+%scan(&MAlist,&index));
         %if (&MaxLags lt &ARMAsum) %then %do;
            %let MaxLags=&ARMAsum;
         %end;
      %end;
      %let MaxLags=%eval(&MaxLags + 3);
      %do index=1 %to &NumAR;
            proc arima data=&TempInput;
               identify var=&HoldVar NLAGS=&MaxLags noprint;
               estimate p=%scan(&ARlist,&index)
                        q=%scan(&MAlist,&index) 
                        method=ml noprint maxiter=500;
               forecast lead=&Holdout out=&Tempfore noprint;
            run;
            quit;
            data &Tempfore;
               merge &Tempfore &DSName;
               keep &TargetVar &HoldVar FORECAST;
            run;
            data &Tempfore;
               set &Tempfore(where=(&HoldVar=.));
            run;
            %GetGOF(DSName=&Tempfore,ActualVar=&TargetVar,
                    ForeVar=FORECAST);
            data &TempAll;
               set &TempAll end=lastobs;
               output;
               if (lastobs) then do;
                  P=%scan(&ARlist,&index);
                  Q=%scan(&MAlist,&index);
                  RMSE=&RMSE;
                  MAPE=&MAPE;
                  output;
               end;
            run;
      %end;
   %end;
   %if (&NumAR ne &NumMA) %then %do;
      %put ERROR: In macro AutoARMA, ARlist=&NumAR MAlist=&NumMA.;
   %end;
   %else %do;
      data &TempAll;
         set &TempAll;
         if (P=.) and (Q=.) then delete;
      run;
      data _null_;
         set &TempAll end=lastobs;
         retain RMSEP RMSEQ MAPEP MAPEQ 0 MinRMSE . MinMAPE .;
         if (MinMAPE=.) and (MAPE>.) then do;
            MinMAPE=MAPE;
            MAPEP=P;
            MAPEQ=Q;
         end;
         if (MinRMSE=.) and (RMSE>.) then do;
            MinRMSE=RMSE;
            RMSEP=P;
            RMSEQ=Q;
         end;
         if (MinMAPE>MAPE>.) then do;
            MinMAPE=MAPE;
            MAPEP=P;
            MAPEQ=Q;
         end;
         if (MinRMSE>RMSE>.) then do;
            MinRMSE=RMSE;
            RMSEP=P;
            RMSEQ=Q;
         end;
         if (lastobs) then do;
            call symput('BestMAPEP',put(MAPEP,z3.0));
            call symput('BestMAPEQ',put(MAPEQ,z3.0));
            call symput('BestRMSEP',put(RMSEP,z3.0));
            call symput('BestRMSEQ',put(RMSEQ,z3.0));
         end;
      run;

         data _null_;
            put "From Macro AutoARMA: &SYSDATE &SYSTIME";
            put "From Macro AutoARMA: Best AR order by MAPE=&BestMAPEP";
            put "From Macro AutoARMA: Best MA order by MAPE=&BestMAPEQ";
            put "From Macro AutoARMA: Best AR order by RMSE=&BestRMSEP";
            put "From Macro AutoARMA: Best MA order by RMSE=&BestRMSEQ";
         run;

      %if (&OutData ne) %then %do;
         data &OutData;
            set &TempAll;
         run;
      %end;
      %DeleteDS(&Tempfore);
      %DeleteDS(&TempAll);
      %DeleteDS(&TempInput);
   %end;
%end;
%else %do;
   %put ERROR: In macro AutoARMAHOmulti, cannot open &DSName;
%end;
%mend AutoARMAHOmulti;

/*---------------------------------------------*\
 |  Macro: ARMAOrders                          |
 +---------------------------------------------+
 |  Suggest two ARMA models (possibly the      |
 |  same) using ESACF and SCAN.                |
\*---------------------------------------------*/

%macro ARMAOrders(DSName=,OutDS=,TargetVar=,DifList=,MaxLag=5);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempData=%RandWorkData();
   %let TempPrint=%RanWinFile();
   filename TempPrin "&TempPrint";
   proc printto print=TempPrin;
   run;
   ods output TentativeOrders=&TempData;
   proc arima data=&DSName;
      %if ("&DifList" eq "") %then %do;
      identify var=&TargetVar
      %end;
      %else %do;
      identify var=&TargetVar(&DifList)
      %end;
               esacf scan minic 
               p=(0:&MaxLag) q=(0:&MaxLag) 
               perror=(3:%eval(2*&MaxLag+2));
   quit;
   ods output close;

   proc summary data=&TempData(where=(SCAN_IC>.Z or ESACF_IC>.Z)) min;
      var SCAN_IC ESACF_IC;
      output out=&OutDS(drop=_TYPE_ _FREQ_) 
             minid(SCAN_IC(SCAN_AR) SCAN_IC(SCAN_MA))=ScanAR ScanMA 
             minid(ESACF_IC(ESACF_AR) ESACF_IC(ESACF_MA))=ESACF_AR ESACF_MA
             ;
   run;
   data &OutDS;
      attrib DSName length=$64 label="Data Set Name"
             ScanAR label="SCAN AR Order"
             ScanMA label="SCAN MA Order"
             ESACF_AR label="ESACF AR Order"
             ESACF_MA label="ESACF_ MA Order"
             ;
      set &OutDS;
      DSName="&DSName";
   run;
   proc printto;
   run;
   filename TempPrin clear;
   %EraseFile(&TempPrint);
   %DeleteDS(&TempData);
%end;
%else %do;
   %put ERROR: In macro ARMAOrders, cannot open &DSName;
%end;
%mend ARMAOrders;

/*---------------------------------------------*\
 |  Macro: AutoAR                              |
 +---------------------------------------------+
 |  Find the best approximating autoregressive |
 |  model.                                     |
 +---------------------------------------------+
 |  Available Criteria                         |
 |                                             |
 |  AIC                                        |
 |  SBC                                        |
 |  FPE                                        |
 |  Hannan-Quinn                               |
 |  CAT                                        |
 |                                             |
\*---------------------------------------------*/
%macro AutoAR(DSName=_LAST_,TargetVar=Target,MaxAR=12,
              DifList=,OutData=,Criterion=SBC);
%if %sysfunc(exist(&DSName)) %then %do;
   /*----  Set up temporary Data  ----*/
   %let Tempstat=%RandWorkData();
   %let TempAll=&Tempstat.ALL;
   %if (&DifList eq) %then %do;
      %let DifList=0;
   %end;

   %let MAXP=&MaxAR;
   %let MaxLags=%eval(&MAXP+1);
   data &TempAll;
      P=.;
      SBC=.;
      AIC=.;
      FPE=.; HannanQuinn=.; ERRORVAR=.;
      NUMRESID=.; SSE=.; LOGLIK=.;
      output;
   run;
   %do ARorder=0 %to &MAXP;
      proc arima data=&DSName;
         identify var=&TargetVar(&DifList) NLAGS=&MaxLags noprint;
         estimate p=&ARorder method=ml noprint
                  outstat=&Tempstat;
      run;
      quit;
      data &Tempstat;
         set &Tempstat;
         retain FOUND 0 AIC . SBC . SSE . LOGLIK .
                ERRORVAR . NUMRESID .;
         if (_STAT_='AIC') then do;
            AIC=_VALUE_;
            FOUND+1;
         end;
         else if (_STAT_='SBC') then do;
            SBC=_VALUE_;
            FOUND+1;
         end;
         else if (_STAT_='SSE') then do;
            SSE=_VALUE_;
            FOUND+1;
         end;
         else if (_STAT_='LOGLIK') then do;
            LOGLIK=_VALUE_;
            FOUND+1;
         end;
         else if (_STAT_='ERRORVAR') then do;
            ERRORVAR=_VALUE_;
            FOUND+1;
         end;
         else if (_STAT_='NUMRESID') then do;
            NUMRESID=_VALUE_;
            FOUND+1;
         end;
         if (FOUND=6) then do;
            P=&ARorder;
            FPE=(NUMRESID+P)*ERRORVAR/(NUMRESID-P);
            C=1.5;
            HannanQuinn=NUMRESID*log(ERRORVAR)+2*C*P*log(log(NUMRESID));
            CheckAIC=NUMRESID*log(ERRORVAR)+2*P;
            output;
            stop;
         end;
         keep P AIC SBC FPE HannanQuinn ERRORVAR NUMRESID SSE LOGLIK;
      run;
      proc append base=&TempAll data=&Tempstat;
      run;
   %end;
   data &TempAll;
      set &TempAll;
      retain VarSum 0;
      if (P=.) then delete;
      else if (P=0) then do;
         ParzenCat=-(1+(1/NUMRESID));
      end;
      else do;
         VarSum=VarSum+(1/ERRORVAR);
         ParzenCat=((1/NUMRESID)*VarSum)-(1/ERRORVAR);
      end;
   run;
   data _null_;
      set &TempAll end=lastobs;
      retain SBCP SBCQ AICP AICQ 0 MinSBC . MinAIC .;
      if (MinAIC=.) and (AIC>.) then do;
         MinAIC=AIC;
         AICP=P;
      end;
      if (MinSBC=.) and (SBC>.) then do;
         MinSBC=SBC;
         SBCP=P;
      end;
      if (MinAIC>AIC>.) then do;
         MinAIC=AIC;
         AICP=P;
      end;
      if (MinSBC>SBC>.) then do;
         MinSBC=SBC;
         SBCP=P;
      end;
      if (lastobs) then do;
         call symput('BestAICP',put(AICP,z3.0));
         call symput('BestSBCP',put(SBCP,z3.0));
      end;
   run;

   data _null_;
      put "From Macro AutoARMA: &SYSDATE &SYSTIME";
      put "From Macro AutoARMA: Best AR order by AIC=&BestAICP";
      put "From Macro AutoARMA: Best AR order by SBC=&BestSBCP";
   run;

   %if (&OutData ne) %then %do;
      data &OutData;
         set &TempAll;
      run;
      proc summary data=&OutData min;
         var AIC SBC FPE HannanQuinn ErrorVar ParzenCat;
         output out=&OutData.Best
                minid(AIC(P))=P_AIC 
                minid(SBC(P))=P_SBC
                minid(FPE(P))=P_FPE 
                minid(HannanQuinn(P))=P_HQ
                minid(ErrorVar(P))=P_EV
                minid(ParzenCat(P))=P_CAT
      run;
      proc print data=&OutData.Best;
         var P_AIC P_SBC P_FPE;
      run;
      proc print data=&OutData.Best;
         var P_HQ P_EV P_CAT;
      run;
      %DeleteDS(&OutData.Best);
   %end;
   %DeleteDS(&Tempstat);
   %DeleteDS(&TempAll);
%end;
%else %do;
   %put ERROR: In macro AutoAR, cannot open &DSName;
%end;
%mend AutoAR;

/*---------------------------------------------*\
 |  Macro: ModelESM                            |
 +---------------------------------------------+
 |  Used by AutoESM to find the best fitting   |
 |  Exponential Smoothing Model.               |
\*---------------------------------------------*/

%macro ModelESM(DSName,DSStat,OutStat,VarName,ModName,Period);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempData=%RandWorkData();
   proc esm data=&DSName
            out=&TempData 
            outstat=&OutStat
            seasonality=&Period
            lead=0;
      forecast &VarName / model=&ModName;
   run;
   data &OutStat;
      attrib Model length=$12 label="ESM Model";
      set &OutStat;
      Model="&ModName";
   run;
   proc append base=&DSStat data=&OutStat;
   run;
   %DeleteDS(&TempData);
%end;
%else %do;
   %put ERROR: In macro ModelESM, cannot open &DSName;
%end;
%mend ModelESM;

/*---------------------------------------------*\
 |  Macro: ModelESM                            |
 +---------------------------------------------+
 |  Using trial-and-error, find the best       |
 |  fitting Exponential Smoothing Model.       |
 +---------------------------------------------+
 |  DSStat contains the output data set of     |
 |  goodness-of-fit statistics.                |
\*---------------------------------------------*/

%macro AutoESM(DSName,DSStat,VarName,DateVar);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempStat=%RandWorkData();
   %let TempOut=&TempStat.o;
   %global SeasonalPeriod TimeInt;
   %GetInterval(&DSName,&DateVar);
   proc esm data=&DSName
            out=&TempOut 
            outstat=&TempStat
            lead=0;
      forecast &VarName / model=Simple;
   run;
   data &DSStat;
      attrib Model length=$12 label="ESM Model";
      set &TempStat;
      Model="Simple";
   run;
   %ModelESM(&DSName,&DSStat,&TempStat,&VarName,Double,&SeasonalPeriod);
   %put ----  Double  -----------------------------------------;
   %ModelESM(&DSName,&DSStat,&TempStat,&VarName,Linear,&SeasonalPeriod);
   %put ----  Linear  -----------------------------------------;
   %ModelESM(&DSName,&DSStat,&TempStat,&VarName,DampTrend,&SeasonalPeriod);
   %put ----  DampTrend  --------------------------------------;
   %if (%eval(&SeasonalPeriod>1) eq 1) %then %do;
   %ModelESM(&DSName,&DSStat,&TempStat,&VarName,Seasonal,&SeasonalPeriod);
   %put ----  Seasonal  ---------------------------------------;
   %ModelESM(&DSName,&DSStat,&TempStat,&VarName,Winters,&SeasonalPeriod);
   %ModelESM(&DSName,&DSStat,&TempStat,&VarName,AddWinters,&SeasonalPeriod);
   %end;
   %DeleteDS(&TempStat);
   %DeleteDS(&TempOut);
%end;
%else %do;
   %put ERROR: In macro AutoESM, cannot open &DSName;
%end;
%mend AutoESM;

/*---------------------------------------------*\
 |  Macro: BestModel                           |
 +---------------------------------------------+
 |  Find best model for 5 statistics.          |
 |  Date set &STatDS must contain variables:   |
 |  Model MAPE RMSE ADJRSQ AIC SBC             |
 +---------------------------------------------+
 |  The macro converts a data set with many    |
 |  models and at least the five variables     |
 |  MAPE, RMSE, ADJRSQ, AIC, and SBC with      |
 |  values for each model. The converted data  |
 |  has five rows and three columns named      |
 |  Model, Statistic, and Value defining the   |
 |  best model based on the given statistic.   |
\*---------------------------------------------*/
%macro BestModel(StatDS,OutDS);
%if %sysfunc(exist(&StatDS)) %then %do;
   proc summary data=&StatDS min max;
      var MAPE RMSE ADJRSQ AIC SBC;
      output out=&OutDS(drop=_TYPE_ _FREQ_)
             min=MinMAPE MinRMSE Dummy1 MinAIC MinSBC
             max=Dummy2 Dummy3 MaxAdjRSQ Dummy4 Dummy5
             minid(MAPE(Model))=MAPEModel 
             minid(RMSE(Model))=RMSEModel
             minid(AIC(Model))=AICModel 
             minid(SBC(Model))=SBCModel
             maxid(ADJRSQ(Model))=ARSQModel
             ;
   run;

   data &OutDS;
      attrib Statistic length=$12 label="Name of Statistic"
             Value     length=8   label="Value of Statistic"
             Model     length=$12 label="Name of Best Model"
             ;
      set &OutDS;
      Value=MinMAPE;
      Statistic="MAPE";
      Model=MAPEModel;
      output;
      Value=MinRMSE;
      Statistic="RMSE";
      Model=RMSEModel;
      output;
      Value=MinAIC;
      Statistic="AIC";
      Model=AICModel;
      output;
      Value=MinSBC;
      Statistic="SBC";
      Model=SBCModel;
      output;
      Value=MaxAdjRSQ;
      Statistic="Adjusted R-Square";
      Model=ARSQModel;
      output;
      keep Statistic Value Model;
   run;
%end;
%else %do;
   %put ERROR: In macro BestModel, cannot open &StatDS;
%end;
%mend BestModel;

/*---------------------------------------------*\
 |  Macro: ExtendData                          |
 +---------------------------------------------+
 |  Add extra dated observations and set the   |
 |  target variable to missing.                |
 +---------------------------------------------+
 |  Useful in conjunction with AddTrend        |
\*---------------------------------------------*/
%macro ExtendData(DSName=,TargetVar=,DateVar=Date,Interval=,Lead=12);
%if %sysfunc(exist(&DSName)) %then %do;
   %if ("%upcase(%scan(&DSName,1))" ne "WORK") and
       (%scan(&DSName,2) ne ) %then %do;
      %put ERROR: Macro ExtendData will not work with permanent data sets.;
   %end;
   %else %do;
   data &DSName; 
      set &DSName end=lastobs;
      output;  
      if (lastobs) then do; 
         &TargetVar=.; 
         do Index=1 to &Lead; 
            &DateVar=intnx("&Interval",Date,1);
            output;
         end;  
      end; 
      keep &DateVar &TargetVar; 
   run;  
   %end;
%end;
%else %do;
   %put ERROR: In macro ExtendData, cannot open &DSName;
%end;
%mend ExtendData; 
/*---------------------------------------------*\
 |  Macro: AddSeasons                          |
 +---------------------------------------------+
 |  Add seasonal dummy variables within a      |
 |  data step.  Time intervals supported:      |
 |  MONTH  WEEK  WEEKDAY  QTR                  |
 |  For seasonal period S, S-1 dummy variables |
 |  are created.                               |
 +---------------------------------------------+
 |  Must be called within a DATA step.         |
\*---------------------------------------------*/
%macro AddSeasons(Type,Prefix,DateVar);
   %if ("%upcase(&Type)"="MONTH") %then %do;
      array Seas{*} &Prefix.1-&Prefix.11;
      do index=1 to 11;
         Seas[index]=0;  /*---- Set seasonal dummies to zero  ----*/
      end;

      if (month(&DateVar)<12) then Seas[month(&DateVar)]=1;
      drop index;
   %end;
   %else %if ("%upcase(&Type)"="WEEK") %then %do;
      array Seas{0:51} &Prefix.0-&Prefix.51;
      do index=0 to 51;
         Seas[index]=0;  /*---- Set seasonal dummies to zero  ----*/
      end;

      if (week(&DateVar)<52) then Seas[week(&DateVar)]=1;
      drop index;
   %end;
   %else %if ("%upcase(&Type)"="WEEKDAY") %then %do;
      array Seas{*} &Prefix.1-&Prefix.6;
      do index=1 to 6;
         Seas[index]=0;  /*---- Set seasonal dummies to zero  ----*/
      end;

      if (weekday(&DateVar)<7) then Seas[weekday(&DateVar)]=1;
      drop index;
   %end;
   %else %if ("%upcase(&Type)"="QTR") %then %do;
      array Seas{*} &Prefix.1-&Prefix.3;
      do index=1 to 3;
         Seas[index]=0;  /*---- Set seasonal dummies to zero  ----*/
      end;

      if (qtr(&DateVar)<4) then Seas[qtr(&DateVar)]=1;
      drop index;
   %end;
%mend AddSeasons;


/*---------------------------------------------*\
 |  Macro: AddTrend                            |
 +---------------------------------------------+
 |  Add deterministic trend variables to a     |
 |  specified data set.                        |
 |  Named arguments are used, and if a named   |
 |  argument is blank, then the corresponding  |
 |  trend variable is not added.               |
 |  By default, a _LINEAR_ trend variable is   |
 |  the only variable that is added.           |
 |  _LINEAR_ trend must be added for           |
 |  calculation of other trend variables.      |
 |  Exponential trend of the type exp(B0+B2*t) |
 |  must be fit using ordinary linear trend on |
 |  a log transformed target variable.         |
 |  Future dates must have been added to the   |
 |  specified data set to calculate future     |
 |  trend values. For example, to add 12       |
 |  future observations for monthly data with  |
 |  target variable TARGET, use                |
 |                                             |
 |  data &DataSet;                             |
 |     set &DataSet end=lastobs;               |
 |     output;                                 |
 |     if (lastobs) then do;                   |
 |        TARGET=.;                            |
 |        do Lead=1 to 12;                     |
 |           Date=intnx('month',Date,1);       |
 |           output;                           |
 |        end;                                 |
 |     end;                                    |
 |  run;                                       |
 +---------------------------------------------+
 |  If DataSet= is not specified, the macro    |
 |  must be called within a DATA step.         |
\*---------------------------------------------*/
%macro AddTrend(DSName=,
                OutDS=,
                LinVar=_LINEAR_,
                QuadVar=,         /*_QUAD_*/
                CubeVar=,         /*_CUBE_*/
                LogitVar=,        /*_LOGIT_*/
                LogVar=,          /*_LOG_*/
                HypVar=,          /*_HYP_*/
                Constant=0
                );
   %if ("&LinVar" eq "") %then %do;
      %let LinVar=_LINEAR_;
   %end;
   %if ("&DSName" ne "") %then %do;
      %if %sysfunc(exist(&DSName)) %then %do;
      %let NumObs=%GetNumObs(&DSName);
      data &OutDS;
         set &DSName;
      %if (%sysevalf(&Constant+0)>0) %then %do;
         retain didtrend 0 Constant &Constant;
         drop didtrend Constant;
      %end;
      %else %do;
         retain didtrend 0;
         drop didtrend;
      %end;
         if (didtrend=0) then do;
            didtrend=1;
            &LinVar=1;
         %if ("&QuadVar" ne "") %then %do;
            &QuadVar=1;
         %end;
         %if ("&CubeVar" ne "") %then %do;
            &CubeVar=1;
         %end;
         %if ("&LogVar" ne "") %then %do;
            &LogVar=0;
         %end;
         %if ("&HypVar" ne "") %then %do;
            &HypVar=1;
         %end;
         %if ("&LogitVar" ne "") and (&Constant>0) %then %do;
            &LogitVar=log(Constant/(1-Constant));
         %end;
         end;
         else do;
            &LinVar+1;
         %if ("&QuadVar" ne "") %then %do;
            &QuadVar=&LinVar*&LinVar;
         %end;
         %if ("&CubeVar" ne "") %then %do;
            &CubeVar=&LinVar*&QuadVar;
         %end;
         %if ("&LogVar" ne "") %then %do;
            &LogVar=log(&LinVar);
         %end;
         %if ("&HypVar" ne "") %then %do;
            &HypVar=1/&LinVar;
         %end;
         %if ("&LogitVar" ne "") and (&Constant>0) %then %do;
            &LogitVar=log(Constant*&LinVar/(1-Constant*&LinVar));
         %end;
         end;
      run;
      %end;
      %else %do;
         %put ERROR: In Macro AddTrend, SAS data set &DSName not found.;
      %end;
   %end;
   %else %do;
      %if (%sysevalf(&Constant+0)>0) %then %do;
         retain didtrend 0 Constant &Constant;
         drop didtrend Constant;
      %end;
      %else %do;
         retain didtrend 0;
         drop didtrend;
      %end;
         if (didtrend=0) then do;
            didtrend=1;
            &LinVar=1;
         %if ("&QuadVar" ne "") %then %do;
            &QuadVar=1;
         %end;
         %if ("&CubeVar" ne "") %then %do;
            &CubeVar=1;
         %end;
         %if ("&LogVar" ne "") %then %do;
            &LogVar=0;
         %end;
         %if ("&HypVar" ne "") %then %do;
            &HypVar=1;
         %end;
         %if ("&LogitVar" ne "") and (&Constant>0) %then %do;
            &LogitVar=log(Constant/(1-Constant));
         %end;
         end;
         else do;
            &LinVar+1;
         %if ("&QuadVar" ne "") %then %do;
            &QuadVar=&LinVar*&LinVar;
         %end;
         %if ("&CubeVar" ne "") %then %do;
            &CubeVar=&LinVar*&QuadVar;
         %end;
         %if ("&LogVar" ne "") %then %do;
            &LogVar=log(&LinVar);
         %end;
         %if ("&HypVar" ne "") %then %do;
            &HypVar=1/&LinVar;
         %end;
         %if ("&LogitVar" ne "") and (&Constant>0) %then %do;
            &LogitVar=log(Constant*&LinVar/(1-Constant*&LinVar));
         %end;
         end;
   %end;
%mend AddTrend;

/*---------------------------------------------*\
 |  Macro: AutoTrend                           |
 +---------------------------------------------+
 |  Macro to automatically fit RWWD and 7      |
 |  trend models to input data and then        |
 |  calculate MAPE and RMSE for each model.    |
\*---------------------------------------------*/
%macro AutoTrend(DSName=,OutDS=,TargetVar=,DateVar=Date,Lead=12);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempData=%RandWorkData();
   %let OutputList=%RanWinFile(Suffix=lst);
   filename ListFile "&OutputList";
   proc printto print=ListFile;
   run;

   proc sql noprint;
      select min(&TargetVar) into :MinTarget
      from &DSName;
   quit;

   /*----  Add Trend Components  ----*/
   %let LeadConst=%sysevalf(1/(%GetNumObs(&DSName)+&Lead));
   %put NOTE: Logistic Trend Constant &LeadConst;
   %AddTrend(DSName=&DSName,
             OutDS=&TempData,
             LinVar=_LINEAR_,
             QuadVar=_QUAD_,
             CubeVar=_CUBE_,
             LogitVar=_LOGIT_,
             LogVar=_LOG_,
             HypVar=_HYP_,
             Constant=&LeadConst);
   
   %if (%sysevalf(&MinTarget+0)>0) %then %do;
   data &TempData;
      set &TempData;
      Log&TargetVar=log(&TargetVar);
   run;
   %end;

   %global TimeInt SeasonalPeriod;
   %GetInterval(&DSName,&DateVar);
   
   proc arima data=&TempData;
      /*----  Random Walk With Drift  ----*/
      identify var=&TargetVar(1) noprint;
      estimate method=ml outstat=&TempData.RWS noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.RW noprint;
      /*----  Linear Trend  ----*/
      identify var=&TargetVar cross=(_LINEAR_) noprint;
      estimate input=(_LINEAR_) method=ml 
               outstat=&TempData.LS noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.L noprint;
      /*----  Quadratic Trend  ----*/
      identify var=&TargetVar cross=(_LINEAR_ _QUAD_) 
               noprint;
      estimate input=(_LINEAR_ _QUAD_) method=ml 
               outstat=&TempData.QS noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.Q noprint;
      /*----  Cubic Trend  ----*/
      identify var=&TargetVar cross=(_LINEAR_ _QUAD_ _CUBE_) 
               noprint;
      estimate input=(_LINEAR_ _QUAD_ _CUBE_) method=ml 
               outstat=&TempData.CS noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.C noprint;
      /*----  Logistic Trend  ----*/
      identify var=&TargetVar cross=(_LOGIT_) 
               noprint;
      estimate input=(_LOGIT_) method=ml 
               outstat=&TempData.LCS noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.LC noprint;
      /*----  Logarithmic Trend  ----*/
      identify var=&TargetVar cross=(_LOG_) noprint;
      estimate input=(_LOG_) method=ml 
               outstat=&TempData.LGS noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.LG noprint;
      /*----  Hyperbolic Trend  ----*/
      identify var=&TargetVar cross=(_HYP_) 
               noprint;
      estimate input=(_HYP_) method=ml 
               outstat=&TempData.HS noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.H noprint;
      /*----  Exponential Trend  ----*/
      %if (%sysevalf(&MinTarget+0)>0) %then %do;
      identify var=Log&TargetVar cross=(_LINEAR_) 
               noprint;
      estimate input=(_LINEAR_) method=ml 
               outstat=&TempData.ES noprint;
      forecast lead=0 id=&DateVar interval=&TimeInt 
               out=&TempData.E noprint;
      %end;
   quit;
   %if (%sysevalf(&MinTarget+0)>0) %then %do;
   %UnLog(&TempData.E,&TargetVar,Log&TargetVar,
          ForecastVar=FORECAST,DateVar=&DateVar);
   proc datasets library=%scan(&TempData.E,1) nolist;
      modify %scan(&TempData.E,2);
      label FORECAST="Forecasts for &TargetVar";
   quit;
   %end;

   data &TempData.IC;
      attrib Model    length=$64 label='Model'
             AIC      length=8   label='AIC'
             SBC      length=8   label='SBC'
             SSE      length=8   label='SSE'
             NUMRESID length=8   label='NUMRESID'
             ERRORVAR length=8   label='ERRORVAR'
             ;
      set &TempData.RWS(in=inrw)
          &TempData.LS(in=inl)
          &TempData.QS(in=inq)
          &TempData.CS(in=inc)
          &TempData.LCS(in=inlc)
          &TempData.LGS(in=inlg)
          &TempData.HS(in=inh)
          %if (%sysevalf(&MinTarget+0)>0) %then %do;
          &TempData.ES(in=ine)
          %end;
          ;
      retain AIC 0 SBC 0 SSE 0 NUMRESID 0 ERRORVAR 0;
      keep Model AIC SBC SSE NUMRESID ERRORVAR;
      if (_STAT_='AIC') then do;
         AIC=_VALUE_;
         SBC=.;
         SSE=.;
         NUMRESID=.;
         ERRORVAR=.;
      end;
      else if (_STAT_='SBC') then SBC=_VALUE_;
      else if (_STAT_='SSE') then SSE=_VALUE_;
      else if (_STAT_='NUMRESID') then NUMRESID=_VALUE_;
      else if (_STAT_='ERRORVAR') then do;
         ERRORVAR=_VALUE_;
         if (inrw=1) then do;
            Model='RWWD';
            output;
         end;
         else if (inl=1) then do;
            Model='Linear';
            output;
         end;
         else if (inq=1) then do;
            Model='Quadratic';
            output;
         end;
         else if (inc=1) then do;
            Model='Cubic';
            output;
         end;
         else if (inlc=1) then do;
            Model='Logistic';
            output;
         end;
         else if (inlg=1) then do;
            Model='Logarithmic';
            output;
         end;
         else if (inh=1) then do;
            Model='Hyperbolic';
            output;
         end;
         else if (ine=1) then do; /*----  Never executed if no Exp  ----*/
            Model='Exponential';
            output;
         end;
      end;
   run;
   proc sort data=&TempData.IC;
      by Model;
   run;

   %global MAPE RMSE;
   %GetGOF(DSName=&TempData.RW,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let RWWDMAPE=&MAPE;
   %let RWWDRMSE=&RMSE;
   %GetGOF(DSName=&TempData.L,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let LinearMAPE=&MAPE;
   %let LinearRMSE=&RMSE;
   %GetGOF(DSName=&TempData.Q,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let QuadMAPE=&MAPE;
   %let QuadRMSE=&RMSE;
   %GetGOF(DSName=&TempData.C,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let CubeMAPE=&MAPE;
   %let CubeRMSE=&RMSE;
   %GetGOF(DSName=&TempData.LC,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let LogitMAPE=&MAPE;
   %let LogitRMSE=&RMSE;
   %GetGOF(DSName=&TempData.LG,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let LogMAPE=&MAPE;
   %let LogRMSE=&RMSE;
   %GetGOF(DSName=&TempData.H,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let HypMAPE=&MAPE;
   %let HypRMSE=&RMSE;
   %if (%sysevalf(&MinTarget+0)>0) %then %do;
   %GetGOF(DSName=&TempData.E,ActualVar=&TargetVar,
           ForeVar=FORECAST);
   %let ExpMAPE=&MAPE;
   %let ExpRMSE=&RMSE;
   %end;


   data &TempData.GOF;
      attrib Model length=$64 label='Model'
             MAPE  length=8   label='MAPE'
             RMSE  length=8   label='RMSE';
      Model='RWWD';
      MAPE=&RWWDMAPE;
      RMSE=&RWWDRMSE;
      output;
      Model='Linear';
      MAPE=&LinearMAPE;
      RMSE=&LinearRMSE;
      output;
      Model='Quadratic';
      MAPE=&QuadMAPE;
      RMSE=&QuadRMSE;
      output;
      Model='Cubic';
      MAPE=&CubeMAPE;
      RMSE=&CubeRMSE;
      output;
      Model='Logistic';
      MAPE=&LogitMAPE;
      RMSE=&LogitRMSE;
      output;
      Model='Logarithmic';
      MAPE=&LogMAPE;
      RMSE=&LogRMSE;
      output;
      Model='Hyperbolic';
      MAPE=&HypMAPE;
      RMSE=&HypRMSE;
      output;
      %if (%sysevalf(&MinTarget+0)>0) %then %do;
      Model='Exponential';
      MAPE=&ExpMAPE;
      RMSE=&ExpRMSE;
      output;
      %end;
   run; 
   proc sort data=&TempData.GOF;
      by Model;
   run;
   data &TempData.GOF;
      merge &TempData.GOF
            &TempData.IC;
      by Model;
      %if (%sysevalf(&MinTarget+0)<=0) %then %do;
         MAPE=-MAPE;
      %end;
   run;

   proc sort data=&TempData.GOF;
      %if (%sysevalf(&MinTarget+0)>0) %then %do;
      by MAPE;
      %end;
      %else %do;
      by RMSE;
      %end;
   run;

   proc sql noprint;
      select max(RMSE) into :MaxRMSE
      from &TempData.GOF;
   quit;
%put DEBUG: MaxRMSE= &MaxRMSE;
   data _null_;
      attrib Hold length=$20;
      max=&MaxRMSE;
      Hold=strip(put(max,20.0));
      L=length(Hold)+1;
      if (L>4) then do;
         Hold=strip('comma'||put(L,z2.0)||'.0');
      end;
      else do;
         Hold='8.3';
      end;
      call symput("MyFormat",Hold);
   run;
%put DEBUG: MyFormat= &MyFormat;

   proc printto;
   run;

   %global HFlag;
   %IsODS_HTML(HFlag);

   %if (&HFlag) %then %do;
      proc print data=&TempData.GOF noobs;
         var Model MAPE RMSE AIC SBC ERRORVAR;
         format MAPE 6.2 RMSE &MyFormat;
      run;
   %end;
   %else %do;
      ods html;
      proc print data=&TempData.GOF noobs;
         var Model MAPE RMSE AIC SBC ERRORVAR;
         format MAPE 6.2 RMSE &MyFormat;
      run;
      ods html close;
   %end;
   %symdel HFlag;

   %if ("&OutDS" ne "") %then %do;
      data &OutDS;
         set &TempData.GOF;
      run;
   %end;
   %if (%sysevalf(&MinTarget+0)<=0) %then %do;
      %put WARNING: MAPE was calculated when &TargetVar<=0.;
   %end;

   %EraseFile(&OutputList);
   %DeleteDS(&TempData);
   %DeleteDS(&TempData.RW);
   %DeleteDS(&TempData.L);
   %DeleteDS(&TempData.Q);
   %DeleteDS(&TempData.C);
   %DeleteDS(&TempData.LC);
   %DeleteDS(&TempData.LG);
   %DeleteDS(&TempData.H);
   %DeleteDS(&TempData.RWS);
   %DeleteDS(&TempData.LS);
   %DeleteDS(&TempData.QS);
   %DeleteDS(&TempData.CS);
   %DeleteDS(&TempData.LCS);
   %DeleteDS(&TempData.LGS);
   %DeleteDS(&TempData.HS);
   %if (%sysevalf(&MinTarget+0)>0) %then %do;
   %DeleteDS(&TempData.ES);
   %DeleteDS(&TempData.E);
   %end;
   %DeleteDS(&TempData.IC);
   %DeleteDS(&TempData.GOF);
   /*
   %DeleteDS(&TempData.SUM); */
%end;
%else %do;
   %put ERROR: In macro AutoTrend, cannot open &DSName;
%end;
%mend AutoTrend;

/*---------------------------------------------*\
 |  Macro: UnLog                               |
 +---------------------------------------------+
 |  Transform FORECAST values when the         |
 |  forecast model is for the log of           |
 |  the time series.                           |
\*---------------------------------------------*/
%macro UnLog(DSName,TargetVar,LogTargetVar,
             ForecastVar=FORECAST,DateVar=Date);
%if %sysfunc(exist(&DSName)) %then %do;
   data &DSName;
      set &DSName;
      &TargetVar=exp(&LogTargetVar);
      &ForecastVar=exp(&ForecastVar+STD*STD/2);
      RESIDUAL=&TargetVar-&ForecastVar;
      L95=exp(L95);
      U95=exp(U95);
      keep &DateVar &TargetVar &ForecastVar RESIDUAL L95 U95 STD;
   run;
%end;
%else %do;
   %put ERROR: In macro UnLog, cannot open &DSName;
%end;
%mend UnLog;

/*---------------------------------------------*\
 |  Macro: LogitConstant                       |
 +---------------------------------------------+
 |  Calculate logit constant LC such that      |
 |                                             |
 |  0<=LC*Y<=1                                 |
 |                                             |
 |  for target variable Y.                     |
\*---------------------------------------------*/
%macro LogitConstant(DSName,TargetVar);
%if %sysfunc(exist(&DSName)) %then %do;
   /*----  Required: %global LogitConstant;  ----*/
   %let TempLogitConst=%RandWorkData();
   proc summary data=&DSName max;
      var &TargetVar;
      output out=&TempLogitConst
             max=max;
   run;
   data _null_;
      set &TempLogitConst;
      lc=0.999999*(10**(-ceil(log10(max))));
      call symput("LogitConstant",lc);
   run;
   %DeleteDS(&TempLogitConst);
%end;
%else %do;
   %put ERROR: In macro LogitConstant, cannot open &DSName;
%end;
%mend LogitConstant;


/*------------------------------------------------*\
 |  Macro: TransformTarget                        |
 +------------------------------------------------+
 |  Transform target variable.  Supported:        |
 |                                                |
 |  LOG  SQRT  EXP  LOGISTIC  BOXCOX(LAMBDA)      |
 |                                                |
 |  Usage:  NewVar=%TransformTarget(OldVar,SQRT); |
 +------------------------------------------------+
 |  NOTE: Useful as a reminder of transformations |
 |        but easier to code most directly.       |
\*------------------------------------------------*/
%macro TransformTarget(TargetVar=,
                       Transform=LOG,
                       TranConstant=0);
   %if ("&TargetVar" ne "") %then %do;
      %if (&TranConstant>0) and 
          ("%upcase(&Transform)" eq "LOGISTIC") %then %do;
         log(&TranConstant*&TargetVar/(1-&TranConstant*&TargetVar))
      %end;
      %else %if ("%upcase(&Transform)" eq "LOG") %then %do;
         log(&TargetVar)
      %end;
      %else %if ("%upcase(&Transform)" eq "SQRT") %then %do;
         sqrt(&TargetVar)
      %end;
      %else %if ("%upcase(&Transform)" eq "EXP") %then %do;
         exp(&TargetVar)
      %end;
      %else %if (&TranConstant>0) and
                ("%upcase(&Transform)" eq "BOXCOX") %then %do;
         ((&TargetVar**&TranConstant)-1))/&TranConstant
      %end;
   %end;
%mend TransformTarget;


/*------------------------------------------------*\
 |  Macro: PartitionData                          |
 +------------------------------------------------+
 |  For specified dataset, create a partition     |
 |  variable with value zero for fit sample and   |
 |  value one for holdout evaluation sample.      |
 +------------------------------------------------+
\*------------------------------------------------*/
%macro PartitionData(DSName=,DateVar=Date,
                     Partition=Partition,
                     Percent=20,Absolute=0);
%if %sysfunc(exist(&DSName)) %then %do;
   data &DSName;
      set &DSName nobs=NumObs;
      attrib &Partition length=3 
                        label='Partition Indicator';
      retain &Partition 0 Cutoff 0 DidIt 0 ObsNo 0;
      if (DidIt=0) then do;
         DidIt=1;
   %if (&Percent >= 1) %then %do;
         Cutoff=floor((100-&Percent)*NumObs/100);
   %end;
   %else %if (&Absolute gt 0) %then %do;
         Cutoff=NumObs-&Absolute;
   %end;
      end;
      ObsNo+1;
      if (ObsNo-1=Cutoff) then &Partition=1;
      drop Cutoff DidIt ObsNo;
   run;
%end;
%else %do;
   %put ERROR: In macro PartitionData, cannot open &DSName;
%end;
%mend PartitionData;


/*-------------------------------------------*\
  -------------------------------------------
  -------------------------------------------
  ----  Statistical calculation section  ----
  -------------------------------------------
  -------------------------------------------
\*-------------------------------------------*/

/*----------------------------------------------*\
 |  Macro: GetMAPE                              |
 +----------------------------------------------+
 |  Calculate RMSE and MAPE for the given data  |
 |  and store in macro variables RMSE and MAPE. |
 |  RMSE=sqrt(SSE/N). To get model-based RMSE   |
 |  for a model with K parameters, calculate    |
 |                                              |
 |  RMSE=sqrt(N/(N-K))*RMSE;                    |
\*----------------------------------------------*/
%macro GetMAPE(DSName=,ActualVar=ACTUAL,ForeVar=FORECAST);
%if %sysfunc(exist(&DSName)) %then %do;
   /*----  Required: %global MAPE; ----*/
   %let MAPE=.;
   data _NULL_;
      set &DSName end=lastobs;
      retain MAPE NMAPE 0;
      Residual=&ActualVar-&ForeVar;
      /*----  SUM function necessary to handle missing  ----*/
      MAPE=sum(MAPE,100*abs(Residual)/&ActualVar);
      NMAPE=NMAPE+N(100*abs(Residual)/&ActualVar);
      if (lastobs) then do;
         MAPE=MAPE/NMAPE;
         call symput('MAPE',strip(put(MAPE,20.4)));
      end;
   run;
%end;
%else %do;
   %put ERROR: In macro GetMAPE cannot open &DSName;
%end;
%mend GetMAPE;

/*----------------------------------------------*\
 |  Macro: GetGOF                               |
 +----------------------------------------------+
 |  Calculate RMSE and MAPE for the given data  |
 |  and store in macro variables RMSE and MAPE. |
 |  RMSE=sqrt(SSE/N). To get model-based RMSE   |
 |  for a model with K parameters, calculate    |
 |                                              |
 |  RMSE=sqrt(N/(N-K))*RMSE;                    |
\*----------------------------------------------*/
%macro GetGOF(DSName=,ActualVar=ACTUAL,ForeVar=FORECAST,NumParm=);
%if %sysfunc(exist(&DSName)) %then %do;
   /*----  Required: %global MAPE RMSE; ----*/
   %let MAPE=.;
   %let RMSE=.;
   data _NULL_;
      set &DSName end=lastobs;
      retain MAPE MSE NMAPE NMSE 0;
      Residual=&ActualVar-&ForeVar;
      /*----  SUM function necessary to handle missing  ----*/
      MAPE=sum(MAPE,100*abs(Residual)/&ActualVar);
      NMAPE=NMAPE+N(100*abs(Residual)/&ActualVar);
      MSE=sum(MSE,Residual**2);
      NMSE=NMSE+N(Residual);
      if (lastobs) then do;
         MAPE=MAPE/NMAPE;
         RMSE=sqrt(MSE/NMSE);
         %if (&NumParm ne) %then %do;
            %if (%eval(&NumParm+0) gt 0) %then %do;
               AIC_SSE=NMSE*log(MSE/NMSE)+2*(&NumParm);
               SBC_SSE=NMSE*log(MSE/NMSE)+(&NumParm)*log(NMSE);
               if (NMSE > &NumParm) then 
                  RMSE=sqrt(NMSE/(NMSE-&NumParm))*RMSE;
               call symput('AIC_SSE',put(AIC_SSE,20.10));
               call symput('SBC_SSE',put(SBC_SSE,20.10));
            %end;
         %end;
         call symput('MAPE',strip(put(MAPE,20.4)));
         call symput('RMSE',put(RMSE,20.10));
      end;
   run;
%end;
%else %do;
   %put ERROR: In macro GetGOF, cannot open &DSName;
%end;
%mend GetGOF;

/*----------------------------------------------*\
 |  Macro: GetGOFstats                          |
 +----------------------------------------------+
 |  Calculate RMSE and MAPE for the given data  |
 |  and store in macro variables RMSE and MAPE. |
 |  RMSE=sqrt(SSE/N). To get model-based RMSE   |
 |  for a model with K parameters, calculate    |
 |                                              |
 |  RMSE=sqrt(N/(N-K))*RMSE;                    |
\*----------------------------------------------*/
%macro GOFstats(ModelName=,DSName=,OutDS=,NumParms=0,
                ActualVar=Actual,ForecastVar=Forecast);
%if %sysfunc(exist(&DSName)) %then %do;
data &OutDS;
   attrib Model length=$32
          MAPE  length=8
          NMAPE length=8
          MSE   length=8
          RMSE  length=8
          NMSE  length=8
          NumParm length=8;
   set &DSName end=lastobs;
   retain MAPE MSE NMAPE NMSE 0 NumParm &NumParms;
   Residual=&ActualVar-&ForecastVar;
   /*----  SUM and N functions necessary to handle missing  ----*/
   MAPE=sum(MAPE,100*abs(Residual)/&ActualVar);
   NMAPE=NMAPE+N(100*abs(Residual)/&ActualVar);
   MSE=sum(MSE,Residual**2);
   NMSE=NMSE+N(Residual);
   if (lastobs) then do;
      Model="&ModelName";
      MAPE=MAPE/NMAPE;
      RMSE=sqrt(MSE/NMSE);
      if (NumParm>0) and (NMSE>NumParm) then 
         RMSE=sqrt(MSE/(NMSE-NumParm));
      else RMSE=sqrt(MSE/NMSE);
      %if (%eval(&NumParms+0>0) eq 1) %then %do;
         AIC_SSE=NMSE*log(MSE/NMSE)+2*(NumParm);
         SBC_SSE=NMSE*log(MSE/NMSE)+(NumParm)*log(NMSE);
      %end;
      output;
   end;
   keep Model MAPE RMSE NumParm
   %if (%eval(&NumParms+0>0) eq 1) %then %do;
        AIC_SSE SBC_SSE
   %end;
        ;
run;
%end;
%else %do;
   %put ERROR: In macro GetGOF, cannot open &DSName;
%end;
%mend GOFstats;


/*---------------------------------------------*\
 |  Macro: GetGOFArima                         |
 +---------------------------------------------+
 |  Using the OUTSTAT= data set from PROC      |
 |  ARIMA, extract goodness-of-fit statistics. |
\*---------------------------------------------*/
%macro GetGOFArima(DSName=,OutDS=,ModelName=);
%if %sysfunc(exist(&DSName)) %then %do;
   proc transpose data=&DSName(drop=_TYPE_) 
                  out=&OutDS(drop=_NAME_ _LABEL_);
      id _STAT_;
      var _VALUE_;
   run;
   data &OutDS;
      attrib Model length=$32 label='Model';
      set &OutDS;
      Model="&ModelName";
   run;
%end;
%else %do;
   %put ERROR: In macro GetGOFArima, cannot open &DSName;
%end;
%mend GetGOFArima;

/*---------------------------*\
 |  Macro: DateRange         |
 +---------------------------+
 |  Find min and max dates.  |
 |  Create macro variables:  |
 |     MinDate               |
 |     MaxDate               |
 |     RangeDate             |
 |  Required:                |
 |  %global MinDate MaxDate  |
 |          RangeDate;       |
\*---------------------------*/
%macro DateRange(DSName,DateVar,TimeInterval);
%if %sysfunc(exist(&DSName)) %then %do;
   %let TempWork=%RandWorkData();
   proc summary data=&DSName min max nway;
      var &DateVar;
      output out=&TempWork
             min=MinDate
             max=MaxDate;
   run;

   data _null_;
      set &TempWork;
      attrib Range length=8 label='Date Range';
      Range=intck("&TimeInterval",MinDate,MaxDate);
      call symput("MinDate",put(MinDate,15.0));
      call symput("MaxDate",put(MaxDate,15.0));
      call symput("RangeDate",put(Range,15.0));
      put "NOTE: Earliest Date=" MinDate date9.;
      put "NOTE: Latest Date=" MaxDate date9.;
      put "NOTE: Date Range=" Range "(&TimeInterval.s)";
   run;
   %DeleteDS(&TempWork);
%end;
%else %do;
   %put ERROR: In macro DateRange, cannot open &DSName;
%end;
%mend DateRange;


/*------------------------------*\
  ------------------------------
  ------------------------------
  ----  Simulation section  ----
  ------------------------------
  ------------------------------
\*------------------------------*/

/*----------------------------------------------------*\
 |  macro: SimARMA.sas                                |
 +----------------------------------------------------+
 |  Simulate and output stationary ARMA time series   |
 |  using the IML ARMASIM function, or alternatively, |
 |  use a SAS data step and the primitive "warm up"   |
 |  method. The warm up period is hardcoded to 1000   |
 |  time points.                                      |
 +----------------------------------------------------+
 |  NOTES                                             |
 +----------------------------------------------------+
 |                                                    |
 |  %SIMARMA(DSName,ARlist,MAlist,Mu,Sigma,Nobs,      |
 |           StartDate,Interval,SEED);                |
 |                                                    |
 |      DSName    - Name of created data              |
 |      ARlist    - List of AR Factor coefficients    |
 |                  leading with Phi_0=1              |
 |      MAlist    - List of MA Factor coefficients    |
 |                  leading with Theta_0=1            |
 |      Mu        - Mean                              |
 |      Sigma     - Error standard deviation          |
 |      Nobs      - Number of data points to simulate |
 |      StartDate - Start date                        |
 |      Interval  - Date interval                     |
 |      SEED      - Random number seed                |
 +----------------------------------------------------+
 |  EXAMPLES                                          |
 +----------------------------------------------------+
%SimARMA(work.temp1,1 -0.5 -0.36,1 0.7,100.0,4.0,240,
         '01JAN1984'd,month,1234321);

%SimARMA(work.temp2,1 -0.9,1,37.0,1.0,240,
         '01JAN1984'd,month,1234321);

%SimARMA(work.temp3,1,1 -0.9,100.0,4.0,240,
         '01JAN1984'd,month,1234321);

%SimARMA(work.temp4,1 -0.9,1 -0.9,1000.0,6.0,240,
         '01JAN1984'd,month,1234321);

%SimARMA(work.temp5,1 -0.5 -0.36,1,337.0,1.44,240,
         '01JAN1984'd,month,1234321);

%SimARMA(work.temp6,1,1 -0.5 -0.36,0.0,1.0,240,
         '01JAN1984'd,month,1234321);
\*----------------------------------------------------*/
%macro SimARMA(DSName,ARlist,MAlist,Mu,Sigma,Nobs,
               StartDate,Interval,SEED);
   %if %sysprod(iml)=1 %then %do;
      %put NOTE: SAS/IML licensed procedure IML found;
      %put NOTE: IML routine ARMASIM used for simulation;
      proc iml;
         reset fuzz noname;
         phi={&ARlist};
         theta={&MAlist};
         nphi=ncol(phi);
         ntheta=ncol(theta);
         mu=&Mu; 
         sigma=&Sigma;     
         nobs=&Nobs; 
         seed=&SEED; 
         Y=armasim(phi,theta,mu,sigma,nobs,seed); 
         oname={'Y'};
         create &DSName from Y[colname=oname];
         append from Y;
         close &DSName;
      quit;
      data &DSName;
         set &DSName;
         attrib DATE length=8 label='Date' format=DATE9.0;
         DATE=intnx("&Interval",&StartDate,_N_-1);
      run;
   %end;
   %else %do;
      %put NOTE: SAS/IML licensed procedure IML not found;
      %put NOTE: SAS DATA step used for simulation;
      %let NumAR=%nlistspace(&ARlist);
      %let NumMA=%nlistspace(&MAlist);
      data &DSName;
         attrib Y length=8;
      %if (&NumAR > 1) %then %do;
         array ARCOEF{%eval(&NumAR-1)} _temporary_;
         array PastY{%eval(&NumAR-1)} _temporary_;
      %end;
      %if (&NumMA > 1) %then %do;
         array MACOEF{%eval(&NumMA-1)} _temporary_;
         array PastE{%eval(&NumMA-1)} _temporary_;
      %end;
         P=&NumAR-1;
         Q=&NumMA-1;
         Mu=&Mu;
         Sigma=&Sigma;
      %if (&NumAR > 1) %then %do;
         do index=1 to P;
            ARCOEF[index]=scan("&ARlist",index+1,' ');
            PastY[index]=Mu;
         end;
      %end;
      %if (&NumMA > 1) %then %do;
         do index=1 to Q;
            MACOEF[index]=scan("&MAlist",index+1,' ');
            PastE[index]=Sigma*rannor(&SEED);
         end;
      %end;
         do NumberObs=1 to 1000;
            Y=0;
      %if (&NumAR > 1) %then %do;
            do index=1 to P;
               Y=Y-ARCOEF[index]*(PastY[index]-Mu);
            end;
      %end;
      %if (&NumMA > 1) %then %do;
            do index=1 to Q;
               Y=Y+MACOEF[index]*PastE[index];
            end;
      %end;
            Error=Sigma*rannor(&SEED);
            Y=Y+Mu+Error;
      %if (&NumAR > 1) %then %do;
            if (P>1) then do;
               do index=P to 2 by -1;
                  PastY[index]=PastY[index-1];
               end;
            end;
            PastY[1]=Y;
      %end;
      %if (&NumMA > 1) %then %do;
            if (Q>1) then do;
               do index=Q to 2 by -1;
                  PastE[index]=PastE[index-1];
               end;
            end;
            PastE[1]=Error;
      %end;
         end;
         do NumberObs=1 to &Nobs;
            Y=0;
      %if (&NumAR > 1) %then %do;
            do index=1 to P;
               Y=Y-ARCOEF[index]*(PastY[index]-Mu);
            end;
      %end;
      %if (&NumMA > 1) %then %do;
            do index=1 to Q;
               Y=Y+MACOEF[index]*PastE[index];
            end;
      %end;
            Error=Sigma*rannor(&SEED);
            Y=Y+Mu+Error;
      %if (&NumAR > 1) %then %do;
            if (P>1) then do;
               do index=P to 2 by -1;
                  PastY[index]=PastY[index-1];
               end;
            end;
            PastY[1]=Y;
      %end;
      %if (&NumMA > 1) %then %do;
            if (Q>1) then do;
               do index=Q to 2 by -1;
                  PastE[index]=PastE[index-1];
               end;
            end;
            PastE[1]=Error;
      %end;
            output;
         end;
         keep Y;
      run;
      data &DSName;
         set &DSName;
         attrib DATE length=8 label='Date' format=DATE9.0;
         DATE=intnx("&Interval",&StartDate,_N_-1);
      run;
   %end;
%mend SimARMA;

/*----------------------------------------------------*\
 |  macro: GetStationary.sas                          |
 +----------------------------------------------------+
 |  Simulate and output coefficients for a            |
 |  stationary and invertible ARMA time series.       |
 +----------------------------------------------------+
 |  NOTES                                             |
 |  Only implemented for real roots.                  |
 +----------------------------------------------------+
 |                                                    |
 |  %GetStationary(Order);                            |
 |                                                    |
 |      Order    - Order of stationary characteristic |
 |                 polynomial                         |
 +----------------------------------------------------+
 |  EXAMPLE:                                          |
 +----------------------------------------------------+
 |  %global PolyCoef;                                 |
 |  %GetStationary(Order=13,RandomSeed=12431);        |
 |  %let ARPOLY=&PolyCoef;                            |
 |  %GetStationary(Order=4,RandomSeed=912867);        |
 |  %let MAPOLY=&PolyCoef;                            |
 |  %SimARMA(work.AR13_4,&ARPOLY,&MAPOLY,37,1.69,84,  |
 |           '01JAN2000'd,month,123641);              |
\*----------------------------------------------------*/

%macro GetStationary(Order=,RandomSeed=);
/*----  %global PolyCoef;  ----*/
   %if %sysprod(iml)=1 %then %do;
      %if (&RandomSeed eq) %then %do;
         data _null_;
            call symput('RandomSeed','0');
         run;
      %end;
      proc iml;
          Roots=j(&Order,1,0);
          call RandSeed(&RandomSeed);
          call randgen(Roots,'UNIFORM');
          Roots=j(&order,1,1)-2*Roots;
          Poly={1}//(-Roots[1]);
          do index=2 to &Order;
             r={1}//(-Roots[index]);
             Poly=t(product(t(r),t(Poly)));
          end;
          OutC=char(Poly);
          OutCC=OutC[1];
          Top=&Order+1;
          do index=2 to Top;
             OutCC=concat(OutCC,concat(' ',OutC[index]));
          end;
          OutCC=compbl(OutCC);
          call symput('PolyCoef',OutCC);
       quit;
   %end;
   %else %do;
      %put ERROR: Licensed Product SAS/IML not found in macro GetStationary.;
   %end;
%mend GetStationary;

/*---------------------------------------------*\
 |  Macro: SimTransfer                         |
 +---------------------------------------------+
 |  Simulate data having target Y and input X  |
 |  having a transfer function with the given  |
 |  number of numerator and denominator lags.  |
 |  X=>Gaussian Normal                         |
 |  Y=>filtered X + Gaussian Normal Error      |
\*---------------------------------------------*/
%macro SimTransfer(OutDS=,NumLags=,DenLags=0,Seed=12321);
/* %let NumLags=1 3 4;
%let DenLags=1;
%let Seed=92621; */
  %if %sysprod(iml)=1 %then %do;
      %let TempWork=%RandWorkData();
      proc iml;
         Phi={&NumLags};
         NumNumLags=ncol(Phi);
         Phi=Phi+j(1,NumNumLags,1);
         Theta={1 &DenLags};
         if (Theta[2]=0) then Theta={1};
         NumDenLags=ncol(Theta);
         MaxNumLag=Phi[NumNumLags];
         MaxDenLag=Theta[NumDenLags];
         NumPoly=j(MaxNumLag,1,0);
         call randseed(&Seed);
         FillPoly=j(MaxNumLag,1,.);
         call randgen(FillPoly,'UNIFORM');
         FillPoly=9.37+11.63*FillPoly;
         NumPoly[Phi]=FillPoly[Phi];
         /*
         DenPoly=j(MaxDenLag,1,0);
         */
         if (NumDenLags=1) then DenPoly={1};
         else DenPoly={1 -0.9};

         Psi=ratio(DenPoly,t(NumPoly),500);
         CutOff=501;
         do index=500 to 1 by -1;
            if (CutOff=501) & (Psi[index]>0.01) then CutOff=index;
         end;
         TranFun=Psi[1:CutOff];
         TranFun=TranFun[CutOff:1];
         Nobs=144+CutOff;
         X=j(Nobs,1,.);
         call randgen(X,'NORMAL',100,5);
         E=j(Nobs,1,.);
         call randgen(E,'NORMAL',0,1);
         Y=j(Nobs,1,.);
         do index=CutOff+1 to Nobs;
            ff=index-CutOff;
            ll=index-1;
            Y[index]= t(TranFun)*X[ff:ll];
         end;

         Y=Y+E;
         ff=CutOff+1;
         ll=nrow(Y);
         Y=Y[ff:ll];
         X=X[ff-1:ll-1];
      
         Lag=1:144;
         Y=t(Lag)||Y||X;
         oname={'Time' 'Y' 'X'};
         create &OutDS from Y[colname=oname];
         append from Y;
         close &OutDS;
      quit;
      data &OutDS;
         attrib Date length=8 label='Date' format=MONYY7.
                Y    label="Target Time Series"
                X    label="Input Time Series";
         set &OutDS;
         retain Date .;
         if (Date=.) then do;
            DATE=intnx("month",'01JAN2009'd,-144);
         end;
         output;
         DATE=intnx("month",Date,1);
      run;
   %end;
   %else %do;
      %put ERROR: Macro SimTransfer requires SAS/IML.;
   %end;
%mend SimTransfer;


/*---------------------------------*\
  ---------------------------------
  ---------------------------------
  ----  Miscellaneous section  ----
  ---------------------------------
  ---------------------------------
\*---------------------------------*/

/*------------------------------------------------*\
 |  Macro: ParmTime                               |
 +------------------------------------------------+
 |  Plot parameter estimates as function of       |
 |  series length to investigate model stability. |
 |  Required: %global MAPE RMSE;                  |
 +------------------------------------------------+
\*------------------------------------------------*/
%macro ParmTime(DSName,TargetVar,StartCount,
                IdentifyOptions,EstimateOptions);
   %DeleteDS(work.EstimatesAll);

   data _null_;
      set &DSNAME end=lastobs;
      retain fobs 0 lobs 0;
      if (&TargetVar>.Z) then do;
         lobs=_N_;
         if (fobs=0) then fobs=_N_;
      end;
      if (lastobs) then do;
         call symput("NumObs",lobs);
         call symput("FirstObs",fobs);
      end;
   run;
   /*---- Initialization  ----*/
   proc arima data=&DSName(firstobs=&FirstObs obs=&NumObs);
      identify &IdentifyOptions noprint;
      estimate &EstimateOptions
               outest=work.EstimatesAll noprint;
      forecast lead=0 out=work.forecast noprint;
   run;
   quit;

   %global MAPE RMSE;
   %GetGOF(DSName=work.forecast,ActualVar=&TargetVar,
           ForeVar=FORECAST);


   %let NumVars=%GetNumVars(work.EstimatesAll);

   data work.EstimatesAll;
      set work.EstimatesAll
         (where=(strip(upcase(_TYPE_))='EST'));
      NumObs=&NumObs-&FirstObs+1;
      DegreesOfFreedom=&NumVars-3;
      MAPE=&MAPE;
      RMSE=&RMSE;
   run;

   %do count=&StartCount %to %eval(&NumObs-1);
      proc arima data=&DSName(firstobs=&FirstObs obs=&count);
         identify &IdentifyOptions noprint;
         estimate &EstimateOptions
                  outest=work.EstimatesOne noprint;
         forecast lead=0 out=work.forecast noprint;
      run;
      quit;
      %GetGOF(DSName=work.forecast,ActualVar=&TargetVar,
              ForeVar=FORECAST);
      %let EstObs=%GetNumObs(work.EstimatesOne);
      %if (&EstObs gt 0) %then %do;
         data EstimatesOne;
            set work.EstimatesOne
                (where=(strip(upcase(_TYPE_))='EST'));
            NumObs=%eval(&Count-&FirstObs+1);
            DegreesOfFreedom=%eval(&NumVars-3);
            MAPE=&MAPE;
            RMSE=&RMSE;
         run;
         proc append base=work.EstimatesAll data=EstimatesOne;
         run;
         proc datasets library=work nolist;
            delete EstimatesOne;
         run;
         quit;
      %end;
      %else %do;
         %let count=%eval(&NumObs+1);
         proc datasets library=work nolist;
            delete EstimatesOne;
         run;
         quit;
      %end;
   %end;
   proc sort data=work.EstimatesAll;
      by NumObs;
   run;
%mend ParmTime;


/*------------------------------------------------*\
 |  Macro: ArimaNoestFile                         |
 +------------------------------------------------+
 |  For the specified OUTMODEL dataset, create a  |
 |  program segment that calls PROC ARIMA with    |
 |  the NOEST option.                             |
 |------------------------------------------------|
\*------------------------------------------------*/
/*------------------------------------------------*\
Variables in OUTMODEL data set:

VarName  Description/Values
-------  ------------------
_NAME_   Target and Inputs
_TYPE_
_STATUS_
_PARM_   MU AR MA NUM DEN DIF
_VALUE_
_STD_
_FACTOR_
_LAG_
_SHIFT_

ParmName  Associated Syntax
--------  -----------------
MU        MU=
AR        P= AR=
MA        Q= MA=
NUM DEN   INPUT= INITVAL=
DIF       CROSS= (IDENTIFY)
\*------------------------------------------------*/

%macro ArimaNoestFile(DSName=,DSModel=,FileName=,
                      OutFor=,Lead=12,EstMethod=ML,
                      DateVar=Date,TimeInterval=NONE);
   /*----  Extract Relevant Info from OUTMODEL file  ----*/
   %let TempData=%RandWorkData();
   data &TempData;
      set &DSModel;
      retain OrderNum 0;
      OrderNum+1;
   run;
   data _null_;
      set &TempData(obs=1);
      call symput('TargetVar',_NAME_);
   run;
   proc sort data=&TempData;
      by _NAME_ _PARM_ _FACTOR_ _LAG_;
   run;
   data _NULL_;
      set &TempData end=lastobs;
      by _NAME_ _PARM_ _FACTOR_ _LAG_;
      retain NumFactors NumLags MaxLength AddLength 0;
      if (first._NAME_) then NumLags=0;
      if (first._PARM_) then do;
         NumFactors=0;
      end;
      if (_NAME_ ^= "&TargetVar") and (_PARM_ in ('NUM','DEN')) then
         NumLags+1;
      if (last._FACTOR_) then do;
         NumFactors+1;
      end;
      if (last._NAME_) then do;
         AddLength=sum(AddLength,60+(NumLags-1)*19);
         output;
      end;
      if (lastobs) then do;
         MaxLength=min(1024,max(AddLength+17,256));
         call symput('LineLength',put(MaxLength,z4.0));
      end;
   run;

/*DEBUG*\
%put "=====> DEBUG <=====";
%put TargetVar=&TargetVar;
%put LineLength=&LineLength;
title3 "===============> DEBUG <===============";
proc print data=&TempData;
run;
title3 ;
%put "=====< DEBUG >=====";
\*DEBUG*/
   
   %DeleteDS(&TempData);

   filename outpsas "&FileName";

   data _null_;
      set &DSModel end=lastobs;
      attrib LastName length=$32
             LastParm length=$32
             TargetVar length=$32
             InputVar  length=$32
             MUString  length=$32
             MAString length=$1024
             ARString length=$1024
             PString length=$1024
             QString length=$1024
             INPUTString length=$1024
             IDINPUTString length=$1024
             IDTargetString length=$1024
             InitvalString length=$1024
             IDVarList length=$1024
             ESVarList length=$1024;
      retain LastName '???'
             LastParm '???'
             TargetVar '???'
             InputVar '???'
             MUString  
             MAString 
             ARString 
             PString 
             QString 
             INPUTString 
             InitvalString
             IDINPUTString
             IDTargetString 
             IDVarList
             ESVarList ' '
             LastLag LastFactor NumIDInputs
             NumEstInputs IsDollar IsCloseParen
             CloseNUM CloseDEN 0;
      /*----  The first observation always  ----*/
      /*----  has the target variable name. ----*/
      if (TargetVar='???') then TargetVar=_NAME_;
      /*----  Parse the possible parm names:  ----*/
      /*----  MU AR MA NUM DEN DIF            ----*/
      if (upcase(_PARM_)='MU') then do;
         MUString=put(_VALUE_,e24.16);
      end;
      else if (upcase(_PARM_)='AR') then do;
         /*----  Terminate last MA factor with a ')'  ----*/
         if (LastParm='MA') then QSTring=strip(QString)||')';
         /*----  ARString is a list of values  ----*/
         /*----  with space separators.        ----*/
         ARString=strip(ARString)||' '||put(_VALUE_,16.12);
         /*----  PString contains the lags  ----*/
         if (LastParm^='AR') then
            /*----  First Factor/First Lag  ----*/
            PSTring='('||strip(put(_LAG_,4.0)); 
         else if (LastFactor=_FACTOR_) then
            /*----  Add to current factor lag list  ----*/
            PSTring=strip(PString)||' '||strip(put(_LAG_,4.0));
         else if (LastFactor^=_FACTOR_) then
            /*----  Start new lag list for subsequent factor  ----*/
            PSTring=strip(PString)||')('||strip(put(_LAG_,4.0));
         /*----  Last factor list is NOT terminated   ----*/
         /*----  with a ')' so the ')' must be added  ----*/
         /*----  after all AR parms are processed.    ----*/
      end;
      else if (upcase(_PARM_)='MA') then do;
         /*----  Terminate last AR factor with a ')'  ----*/
         if (LastParm='AR') then PSTring=strip(PString)||')';
         /*----  MAString is a list of values  ----*/
         /*----  with space separators.        ----*/
         MAString=strip(MAString)||' '||put(_VALUE_,16.12);
         if (LastParm^='MA') then
            /*----  First Factor/First Lag  ----*/
            QString='('||strip(put(_LAG_,4.0));
         else if (LastFactor=_FACTOR_) then
            /*----  Add to current factor lag list  ----*/
            QString=strip(QString)||' '||strip(put(_LAG_,4.0));
         else if (LastFactor^=_FACTOR_) then
            /*----  Start new lag list for subsequent factor  ----*/
            QString=strip(QString)||')('||strip(put(_LAG_,4.0));
         /*----  Last factor list is NOT terminated   ----*/
         /*----  with a ')' so the ')' must be added  ----*/
         /*----  after all AR parms are processed.    ----*/
      end;
      else if (upcase(_PARM_)='NUM') then do;
         /*----  Terminate last AR or MA factor with a ')'  ----*/
         if (LastParm='AR') then PSTring=strip(PString)||')';
         if (LastParm='MA') then QSTring=strip(QString)||')';
         if (CloseDEN=1) then do;
            CloseDEN=0;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')'||InputVar;
            end;
            else INPUTString=strip(InputString)||' '||InputVar;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||' '||InputVar;
            end;
            else
               InitvalString=strip(InitvalString)||')'||InputVar;
         end;
         /*----  If last NAME is different, then the current  ----*/
         /*----  NAME must be for an INPUT variable.          ----*/
         if (LastName^=_NAME_) then do;
            NumEstInputs+1;
            if (NumEstInputs=1) then do;
               /*----  Initialize INPUT and INITVAL      ----*/
               /*----  strings for first INPUT variable. ----*/
               if (_SHIFT_>0) then do;
                  IsCloseParen=1;
                  INPUTString=strip(put(_SHIFT_,3.0))||'$('||strip(put(_LAG_,4.0));
               end;
               else if (_LAG_>0) then do;
                  INPUTString='('||strip(put(_LAG_,4.0));
                  IsCloseParen=1;
               end;
               InitvalString=put(_VALUE_,e24.16)||'$';
               IsDollar=1;
            end;
            else do;
               /*----  Terminate the last INPUT string  ----*/
               /*----  with a ')' and the last INPUT    ----*/
               /*----  variable name. Do the same       ----*/
               /*----  thing for the INITVAL string.    ----*/
               if (IsCloseParen=1) then do;
                  IsCloseParen=0;
                  INPUTString=strip(InputString)||')'||InputVar;
                  if (IsDollar=1) then do;
                     IsDollar=0;
                     InitvalString=strip(InitvalString)||' '||InputVar;
                  end;
                  else
                     InitvalString=strip(InitvalString)||')'||InputVar;
               end;
               else if (CloseNum=1) or (CloseDEN=1) then do;
                  CloseNUM=0;
                  CloseDEN=0;
                  INPUTString=strip(InputString)||' '||InputVar;
                  if (IsDollar=1) then do;
                     IsDollar=0;
                     InitvalString=strip(InitvalString)||' '||InputVar;
                  end;
                  else
                     InitvalString=strip(InitvalString)||')'||InputVar;
               end;
               /*----  Add to INPUT and INITVAL string in      ----*/
               /*----  preparation for the new INPUT variable. ----*/
               /*----  The first INITVAL value cannot be       ----*/
               /*----  placed inside parentheses.              ----*/
               if (_SHIFT_>0) then do;
                  INPUTString=strip(InputString)||' '||strip(put(_SHIFT_,3.0))||'$('||strip(put(_LAG_,4.0));
                  IsCloseParen=1;
                  InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16)||'$';
               end;
               else do;
                  if (_LAG_>0) then do;
                     INPUTString=strip(INPUTString)||' ('||strip(put(_LAG_,4.0));
                     IsCloseParen=1;
                  end;
                  InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16)||'$';
               end;
               /*----  At this point, the INITVAL string has a separating  ----*/
               /*----  '$' but no starting parenthesis '('. The '(' must   ----*/
               /*----  be added if there is more than one numerator lag    ----*/
               /*----  for the given factor. The requirement for a '('     ----*/
               /*----  can only be made after processing the next          ----*/
               /*----  observation.                                        ----*/
               IsDollar=1;
            end;
            /*----  The value of InputVar is updated AFTER  ----*/
            /*----  all of the INPUT and INITVAL strings    ----*/
            /*----  are terminated for the previous INPUT.  ----*/
            InputVar=_NAME_;
            ESVarList=strip(ESVarList)||''||InputVar;
         end;
         /*----  Add to INPUT and INITVAL strings for    ----*/
         /*----  continuation of current INPUT variable. ----*/
         else do;
            /*----  Continuation for input AND factor.  ----*/
            if (LastFactor=_FACTOR_) then do;
               /*----  If INITVAL ended with a '$',  ----*/
               /*----  it must start with a '('.     ----*/
               if (IsDollar=1) then do;
                  IsDollar=0;
                  InitvalString=strip(InitvalString)||'(';
                  IsCloseParen=1;
               end;
            end;
            /*----  Continuation for INPUT, but new FACTOR  ----*/
            else do;
               INPUTString=strip(INPUTString)||')(';
               InitvalString=strip(InitvalString)||')(';
               IsCloseParen=1;
            end;
            if (_LAG_>0) then INPUTString=strip(INPUTString)||' '||strip(put(_LAG_,4.0));
            InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16);
         end;
         CloseNUM=1;
      end;
      else if (upcase(_PARM_)='DEN') then do;
         /*----  NUM followed by DEN always closes NUM  ----*/
         CloseNUM=0;
         /*----  Last parm MUST be NUM or DEN  ----*/
         if (LastParm='NUM') then do;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||'/('||put(_VALUE_,e24.16);
            end;
            else do;
               InitvalString=strip(InitvalString)||')/('||put(_VALUE_,e24.16);
            end;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')/('||strip(put(_LAG_,4.0));
            end;
            else do;
               INPUTString=strip(InputString)||'/('||strip(put(_LAG_,4.0));
            end;
            IsCloseParen=1;
         end;
         /*----  Second or subsequent DEN parm.  ----*/
         else do;
            if (LastFactor=_FACTOR_) then do;
               INPUTString=strip(InputString)||' '||strip(put(_LAG_,4.0));
               InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16);
            end;
            else do;
               INPUTString=strip(InputString)||')('||strip(put(_LAG_,4.0));
               InitvalString=strip(InitvalString)||')('||put(_VALUE_,e24.16);
               IsCloseParen=1;
            end;
         end;
         /*----  Add closing parenthesis ')' and/or NAME     ----*/
         /*----  when a new INPUT or new PARM is encountered.----*/
         CloseDEN=1;
      end;
      else if (upcase(_PARM_)='DIF') then do;
         if (_NAME_^=TargetVar) then do;
            if (LastName^=_NAME_) then do;
               NumIDInputs+1;
               IDVarList=strip(IDVarList)||' '||_NAME_;
            end;
         end;
         if (LastParm='AR') then PString=strip(PString)||')';
         else if (LastParm='MA') then QSTring=strip(QString)||')';
         if (CloseNUM=1) or (CloseDEN=1) then do;
            CloseDEN=0;
            CloseNUM=0;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')'||InputVar;
            end;
            else INPUTString=strip(InputString)||' '||InputVar;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||' '||InputVar;
            end;
            else
               InitvalString=strip(InitvalString)||')'||InputVar;
         end;
         if (LastParm^='DIF') then do;
            if (TargetVar=_NAME_) then do;
               IDTargetString=strip(TargetVar)||'('||strip(put(_LAG_,4.0));
            end;
            else do;
               IDINPUTString=strip(_NAME_)||'('||strip(put(_LAG_,4.0));
            end; 
         end;
         else do; 
            if (TargetVar=_NAME_) then do;
               IDTargetString=strip(IDTargetString)||' '||strip(put(_LAG_,4.0));
            end;
            else do;
               if (LastName^=_NAME_) then do;
                  if (LastName=TargetVar) then
                     IDINPUTString=strip(IDINPUTString)||' '||_NAME_||'('||strip(put(_LAG_,4.0));
                  else
                     IDINPUTString=strip(IDINPUTString)||') '||_NAME_||'('||strip(put(_LAG_,4.0));
               end;
               else do;
                  IDINPUTString=strip(IDINPUTString)||' '||strip(put(_LAG_,4.0));
               end;
            end; 
         end;
      end;
/*DEBUG*\
put _NAME_= _PARM_= _LAG_= _SHIFT_=;
put NumIDInputs= NumEstInputs=;
put TargetVar= InputVar=;
put INPUTString=;
put InitvalString=;
put IDINPUTString=;
put ESVarList=;
put IsDollar= IsCloseParen= CloseNUM= CloseDEN=;
put '==============================';
\*DEBUG*/
      if (lastobs) then do;
         if (_PARM_='AR') then PSTring=strip(PString)||')';
         else if (_PARM_='MA') then QSTring=strip(QString)||')';
         if (CloseNUM=1) or (CloseDEN=1) then do;
            CloseDEN=0;
            CloseNUM=0;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')'||InputVar;
            end;
            else INPUTString=strip(InputString)||' '||InputVar;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||' '||InputVar;
            end;
            else
               InitvalString=strip(InitvalString)||')'||InputVar;
         end;
         INPUTString='('||strip(INPUTString)||')';
         InitvalString='('||strip(InitvalString)||')';
         if (IDTargetString eq ' ') then do;
            IDTargetString=TargetVar;
         end;
         else do;
            IDTargetString=strip(IDTargetString)||')';
         end;
         /*----  Make sure all INPUTs are in CROSS option  ----*/
         if (NumIDInputs>=1) then 
            IDINPUTString=strip(IDINPUTString)||')';
         if (NumEstInputs>NumIDInputs) then do;
            do VarNum=1 to NumEstInputs;
               LastName=scan(ESVarList,VarNum,' ');
               if (index(IDVarList,LastName)=0) then do;
                  IDINPUTString=strip(IDINPUTString)||' '||LastName;
               end;
            end;
         end;
         /* DEBUG
         put MUString;
         put PString;
         put ARString;
         put QString;
         put MAString;
         put INPUTString;
         put InitvalString;
         put IDTargetString;
         put IDINPUTString;
         put NumEstInputs=;
         put NumIDInputs=;
         */
         file outpsas linesize=&LineLength;
         put "proc arima data=&DSName;";

         put "   identify var=" IDTargetString ;
         if (NumEstInputs>0) then do;
            put "           cross=(" IDINPUTString ")";
         end;
         put "           noprint;";
         put "   estimate ";
         if (PSTring ne ' ') then do;
            put "            P=" PSTring; 
            put "            AR=" ARString;
         end;
         if (QSTring ne ' ') then do;
            put "            Q=" QString;
            put "            MA=" MAString;
         end;
         if (NumEstInputs>0) then do;
            put "            INPUT=" INPUTString;
            put "            INITVAL=" InitvalString;
         end;
         if (MUString ne ' ') then do;
            put "            MU=" MUString;
         end;
         put "            noest method=&EstMethod noprint;";
         %if ("&TimeInterval" eq "NONE") %then %do;
         put "   forecast out=&OutFor lead=&Lead noprint;";
         %end;
         %else %do;
         put "   forecast out=&OutFor lead=&Lead ID=&DateVar INTERVAL=&TimeInterval noprint;";
         %end;
         put "quit;";
/*DEBUG*\
file log;
put _NAME_= _PARM_= _LAG_= _SHIFT_=;
put NumIDInputs= NumEstInputs=;
put TargetVar= InputVar=;
put INPUTString=;
put InitvalString=;
put IDINPUTString=;
put ESVarList=;
put IsDollar= IsCloseParen= CloseNUM= CloseDEN=;
put '==============================';
\*DEBUG*/
      end;
      LastLag=_LAG_;
      LastParm=_PARM_;
      LastFactor=_FACTOR_;
      LastName=_NAME_;
   run;
%mend ArimaNoestFile;

/*---------------------------------------------*\
 |  Macro: ArimaNoest                          |
 +---------------------------------------------+
 |  Same as ArimaNoestFile, except the file    |
 |  is created, %included, and then erased.    |
 |  Forecasts are created and stored in the    |
 |  OutFor dataset.                            |
\*---------------------------------------------*/
%macro ArimaNoest(DSName=,DSModel=,OutFor=,Lead=12,
                  EstMethod=ML,
                  DateVar=Date,TimeInterval=NONE);
   /*----  Extract Relevant Info from OUTMODEL file  ----*/
   %let TempData=%RandWorkData();
   data &TempData;
      set &DSModel;
      retain OrderNum 0;
      OrderNum+1;
   run;
   data _null_;
      set &TempData(obs=1);
      call symput('TargetVar',_NAME_);
   run;
   proc sort data=&TempData;
      by _NAME_ _PARM_ _FACTOR_ _LAG_;
   run;
   data _null_;
      set &TempData end=lastobs;
      by _NAME_ _PARM_ _FACTOR_ _LAG_;
      retain NumFactors NumLags MaxLength AddLength 0;
      if (first._NAME_) then NumLags=0;
      if (first._PARM_) then do;
         NumFactors=0;
      end;
      if (_NAME_ ^= "&TargetVar") and (_PARM_ in ('NUM','DEN')) then
         NumLags+1;
      if (last._FACTOR_) then do;
         NumFactors+1;
      end;
      if (last._NAME_) then do;
         AddLength=sum(AddLength,60+(NumLags-1)*19);
         output;
      end;
      if (lastobs) then do;
         MaxLength=min(1024,max(AddLength+17,256));
         call symput('LineLength',put(MaxLength,z4.0));
      end;
   run;

   %DeleteDS(&TempData);

   %let WorkSAS=%RanWorkFile();
   filename outpsas "&WorkSAS";
   data _null_;
      set &DSModel end=lastobs;
      attrib LastName length=$32
             LastParm length=$32
             TargetVar length=$32
             InputVar  length=$32
             MUString  length=$32
             MAString length=$1024
             ARString length=$1024
             PString length=$1024
             QString length=$1024
             INPUTString length=$1024
             IDINPUTString length=$1024
             IDTargetString length=$1024
             InitvalString length=$1024
             IDVarList length=$1024
             ESVarList length=$1024;
      retain LastName '???'
             LastParm '???'
             TargetVar '???'
             InputVar '???'
             MUString  
             MAString 
             ARString 
             PString 
             QString 
             INPUTString 
             InitvalString
             IDINPUTString
             IDTargetString 
             IDVarList
             ESVarList ' '
             LastLag LastFactor NumIDInputs
             NumEstInputs IsDollar IsCloseParen
             CloseNUM CloseDEN 0;
      /*----  The first observation always  ----*/
      /*----  has the target variable name. ----*/
      if (TargetVar='???') then TargetVar=_NAME_;
      /*----  Parse the possible parm names:  ----*/
      /*----  MU AR MA NUM DEN DIF            ----*/
      if (upcase(_PARM_)='MU') then do;
         MUString=put(_VALUE_,e24.16);
      end;
      else if (upcase(_PARM_)='AR') then do;
         /*----  Terminate last MA factor with a ')'  ----*/
         if (LastParm='MA') then QSTring=strip(QString)||')';
         /*----  ARString is a list of values  ----*/
         /*----  with space separators.        ----*/
         ARString=strip(ARString)||' '||put(_VALUE_,16.12);
         /*----  PString contains the lags  ----*/
         if (LastParm^='AR') then
            /*----  First Factor/First Lag  ----*/
            PSTring='('||strip(put(_LAG_,4.0)); 
         else if (LastFactor=_FACTOR_) then
            /*----  Add to current factor lag list  ----*/
            PSTring=strip(PString)||' '||strip(put(_LAG_,4.0));
         else if (LastFactor^=_FACTOR_) then
            /*----  Start new lag list for subsequent factor  ----*/
            PSTring=strip(PString)||')('||strip(put(_LAG_,4.0));
         /*----  Last factor list is NOT terminated   ----*/
         /*----  with a ')' so the ')' must be added  ----*/
         /*----  after all AR parms are processed.    ----*/
      end;
      else if (upcase(_PARM_)='MA') then do;
         /*----  Terminate last AR factor with a ')'  ----*/
         if (LastParm='AR') then PSTring=strip(PString)||')';
         /*----  MAString is a list of values  ----*/
         /*----  with space separators.        ----*/
         MAString=strip(MAString)||' '||put(_VALUE_,16.12);
         if (LastParm^='MA') then
            /*----  First Factor/First Lag  ----*/
            QString='('||strip(put(_LAG_,4.0));
         else if (LastFactor=_FACTOR_) then
            /*----  Add to current factor lag list  ----*/
            QString=strip(QString)||' '||strip(put(_LAG_,4.0));
         else if (LastFactor^=_FACTOR_) then
            /*----  Start new lag list for subsequent factor  ----*/
            QString=strip(QString)||')('||strip(put(_LAG_,4.0));
         /*----  Last factor list is NOT terminated   ----*/
         /*----  with a ')' so the ')' must be added  ----*/
         /*----  after all AR parms are processed.    ----*/
      end;
      else if (upcase(_PARM_)='NUM') then do;
         /*----  Terminate last AR or MA factor with a ')'  ----*/
         if (LastParm='AR') then PSTring=strip(PString)||')';
         if (LastParm='MA') then QSTring=strip(QString)||')';
         if (CloseDEN=1) then do;
            CloseDEN=0;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')'||InputVar;
            end;
            else INPUTString=strip(InputString)||' '||InputVar;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||' '||InputVar;
            end;
            else
               InitvalString=strip(InitvalString)||')'||InputVar;
         end;
         /*----  If last NAME is different, then the current  ----*/
         /*----  NAME must be for an INPUT variable.          ----*/
         if (LastName^=_NAME_) then do;
            NumEstInputs+1;
            if (NumEstInputs=1) then do;
               /*----  Initialize INPUT and INITVAL      ----*/
               /*----  strings for first INPUT variable. ----*/
               if (_SHIFT_>0) then do;
                  IsCloseParen=1;
                  INPUTString=strip(put(_SHIFT_,3.0))||'$('||strip(put(_LAG_,4.0));
               end;
               else if (_LAG_>0) then do;
                  INPUTString='('||strip(put(_LAG_,4.0));
                  IsCloseParen=1;
               end;
               InitvalString=put(_VALUE_,e24.16)||'$';
               IsDollar=1;
            end;
            else do;
               /*----  Terminate the last INPUT string  ----*/
               /*----  with a ')' and the last INPUT    ----*/
               /*----  variable name. Do the same       ----*/
               /*----  thing for the INITVAL string.    ----*/
               if (IsCloseParen=1) then do;
                  IsCloseParen=0;
                  INPUTString=strip(InputString)||')'||InputVar;
                  if (IsDollar=1) then do;
                     IsDollar=0;
                     InitvalString=strip(InitvalString)||' '||InputVar;
                  end;
                  else
                     InitvalString=strip(InitvalString)||')'||InputVar;
               end;
               else if (CloseNum=1) or (CloseDEN=1) then do;
                  CloseNUM=0;
                  CloseDEN=0;
                  INPUTString=strip(InputString)||' '||InputVar;
                  if (IsDollar=1) then do;
                     IsDollar=0;
                     InitvalString=strip(InitvalString)||' '||InputVar;
                  end;
                  else
                     InitvalString=strip(InitvalString)||')'||InputVar;
               end;
               /*----  Add to INPUT and INITVAL string in      ----*/
               /*----  preparation for the new INPUT variable. ----*/
               /*----  The first INITVAL value cannot be       ----*/
               /*----  placed inside parentheses.              ----*/
               if (_SHIFT_>0) then do;
                  INPUTString=strip(InputString)||' '||strip(put(_SHIFT_,3.0))||'$('||strip(put(_LAG_,4.0));
                  IsCloseParen=1;
                  InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16)||'$';
               end;
               else do;
                  if (_LAG_>0) then do;
                     INPUTString=strip(INPUTString)||' ('||strip(put(_LAG_,4.0));
                     IsCloseParen=1;
                  end;
                  InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16)||'$';
               end;
               /*----  At this point, the INITVAL string has a separating  ----*/
               /*----  '$' but no starting parenthesis '('. The '(' must   ----*/
               /*----  be added if there is more than one numerator lag    ----*/
               /*----  for the given factor. The requirement for a '('     ----*/
               /*----  can only be made after processing the next          ----*/
               /*----  observation.                                        ----*/
               IsDollar=1;
            end;
            /*----  The value of InputVar is updated AFTER  ----*/
            /*----  all of the INPUT and INITVAL strings    ----*/
            /*----  are terminated for the previous INPUT.  ----*/
            InputVar=_NAME_;
            ESVarList=strip(ESVarList)||''||InputVar;
         end;
         /*----  Add to INPUT and INITVAL strings for    ----*/
         /*----  continuation of current INPUT variable. ----*/
         else do;
            /*----  Continuation for input AND factor.  ----*/
            if (LastFactor=_FACTOR_) then do;
               /*----  If INITVAL ended with a '$',  ----*/
               /*----  it must start with a '('.     ----*/
               if (IsDollar=1) then do;
                  IsDollar=0;
                  InitvalString=strip(InitvalString)||'(';
                  IsCloseParen=1;
               end;
            end;
            /*----  Continuation for INPUT, but new FACTOR  ----*/
            else do;
               INPUTString=strip(INPUTString)||')(';
               InitvalString=strip(InitvalString)||')(';
               IsCloseParen=1;
            end;
            if (_LAG_>0) then INPUTString=strip(INPUTString)||' '||strip(put(_LAG_,4.0));
            InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16);
         end;
         CloseNUM=1;
      end;
      else if (upcase(_PARM_)='DEN') then do;
         /*----  NUM followed by DEN always closes NUM  ----*/
         CloseNUM=0;
         /*----  Last parm MUST be NUM or DEN  ----*/
         if (LastParm='NUM') then do;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||'/('||put(_VALUE_,e24.16);
            end;
            else do;
               InitvalString=strip(InitvalString)||')/('||put(_VALUE_,e24.16);
            end;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')/('||strip(put(_LAG_,4.0));
            end;
            else do;
               INPUTString=strip(InputString)||'/('||strip(put(_LAG_,4.0));
            end;
            IsCloseParen=1;
         end;
         /*----  Second or subsequent DEN parm.  ----*/
         else do;
            if (LastFactor=_FACTOR_) then do;
               INPUTString=strip(InputString)||' '||strip(put(_LAG_,4.0));
               InitvalString=strip(InitvalString)||' '||put(_VALUE_,e24.16);
            end;
            else do;
               INPUTString=strip(InputString)||')('||strip(put(_LAG_,4.0));
               InitvalString=strip(InitvalString)||')('||put(_VALUE_,e24.16);
               IsCloseParen=1;
            end;
         end;
         /*----  Add closing parenthesis ')' and/or NAME     ----*/
         /*----  when a new INPUT or new PARM is encountered.----*/
         CloseDEN=1;
      end;
      else if (upcase(_PARM_)='DIF') then do;
         if (_NAME_^=TargetVar) then do;
            if (LastName^=_NAME_) then do;
               NumIDInputs+1;
               IDVarList=strip(IDVarList)||' '||_NAME_;
            end;
         end;
         if (LastParm='AR') then PString=strip(PString)||')';
         else if (LastParm='MA') then QSTring=strip(QString)||')';
         if (CloseNUM=1) or (CloseDEN=1) then do;
            CloseDEN=0;
            CloseNUM=0;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')'||InputVar;
            end;
            else INPUTString=strip(InputString)||' '||InputVar;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||' '||InputVar;
            end;
            else
               InitvalString=strip(InitvalString)||')'||InputVar;
         end;
         if (LastParm^='DIF') then do;
            if (TargetVar=_NAME_) then do;
               IDTargetString=strip(TargetVar)||'('||strip(put(_LAG_,4.0));
            end;
            else do;
               IDINPUTString=strip(_NAME_)||'('||strip(put(_LAG_,4.0));
            end; 
         end;
         else do; 
            if (TargetVar=_NAME_) then do;
               IDTargetString=strip(IDTargetString)||' '||strip(put(_LAG_,4.0));
            end;
            else do;
               if (LastName^=_NAME_) then do;
                  if (LastName=TargetVar) then
                     IDINPUTString=strip(IDINPUTString)||' '||_NAME_||'('||strip(put(_LAG_,4.0));
                  else
                     IDINPUTString=strip(IDINPUTString)||') '||_NAME_||'('||strip(put(_LAG_,4.0));
               end;
               else do;
                  IDINPUTString=strip(IDINPUTString)||' '||strip(put(_LAG_,4.0));
               end;
            end; 
         end;
      end;
/*DEBUG*\
put _NAME_= _PARM_= _LAG_= _SHIFT_=;
put NumIDInputs= NumEstInputs=;
put TargetVar= InputVar=;
put INPUTString=;
put InitvalString=;
put IDINPUTString=;
put ESVarList=;
put IsDollar= IsCloseParen= CloseNUM= CloseDEN=;
put '==============================';
\*DEBUG*/
      if (lastobs) then do;
         if (_PARM_='AR') then PSTring=strip(PString)||')';
         else if (_PARM_='MA') then QSTring=strip(QString)||')';
         if (CloseNUM=1) or (CloseDEN=1) then do;
            CloseDEN=0;
            CloseNUM=0;
            if (IsCloseParen=1) then do;
               IsCloseParen=0;
               INPUTString=strip(InputString)||')'||InputVar;
            end;
            else INPUTString=strip(InputString)||' '||InputVar;
            if (IsDollar=1) then do;
               IsDollar=0;
               InitvalString=strip(InitvalString)||' '||InputVar;
            end;
            else
               InitvalString=strip(InitvalString)||')'||InputVar;
         end;
         INPUTString='('||strip(INPUTString)||')';
         InitvalString='('||strip(InitvalString)||')';
         if (IDTargetString eq ' ') then do;
            IDTargetString=TargetVar;
         end;
         else do;
            IDTargetString=strip(IDTargetString)||')';
         end;
         /*----  Make sure all INPUTs are in CROSS option  ----*/
         if (NumIDInputs>=1) then 
            IDINPUTString=strip(IDINPUTString)||')';
         if (NumEstInputs>NumIDInputs) then do;
            do VarNum=1 to NumEstInputs;
               LastName=scan(ESVarList,VarNum,' ');
               if (index(IDVarList,LastName)=0) then do;
                  IDINPUTString=strip(IDINPUTString)||' '||LastName;
               end;
            end;
         end;
         /* DEBUG
         put MUString;
         put PString;
         put ARString;
         put QString;
         put MAString;
         put INPUTString;
         put InitvalString;
         put IDTargetString;
         put IDINPUTString;
         put NumEstInputs=;
         put NumIDInputs=;
         */
         file outpsas linesize=&LineLength;
         put "proc arima data=&DSName;";

         put "   identify var=" IDTargetString ;
         if (NumEstInputs>0) then do;
            put "           cross=(" IDINPUTString ")";
         end;
         put "           noprint;";
         put "   estimate ";
         if (PSTring ne ' ') then do;
            put "            P=" PSTring; 
            put "            AR=" ARString;
         end;
         if (QSTring ne ' ') then do;
            put "            Q=" QString;
            put "            MA=" MAString;
         end;
         if (NumEstInputs>0) then do;
            put "            INPUT=" INPUTString;
            put "            INITVAL=" InitvalString;
         end;
         if (MUString ne ' ') then do;
            put "            MU=" MUString;
         end;
         put "            noest method=&EstMethod noprint;";
         %if ("&TimeInterval" eq "NONE") %then %do;
         put "   forecast out=&OutFor lead=&Lead noprint;";
         %end;
         %else %do;
         put "   forecast out=&OutFor lead=&Lead ID=&DateVar INTERVAL=&TimeInterval noprint;";
         %end;
         put "quit;";
/*DEBUG*\
file log;
put _NAME_= _PARM_= _LAG_= _SHIFT_=;
put NumIDInputs= NumEstInputs=;
put TargetVar= InputVar=;
put INPUTString=;
put InitvalString=;
put IDINPUTString=;
put ESVarList=;
put IsDollar= IsCloseParen= CloseNUM= CloseDEN=;
put '==============================';
\*DEBUG*/
      end;
      LastLag=_LAG_;
      LastParm=_PARM_;
      LastFactor=_FACTOR_;
      LastName=_NAME_;
   run;
   %include outpsas / lrecl=&LineLength;
   %EraseFile(&WorkSAS);
%mend ArimaNoest;

/*---------------------------------------------------*\
 |  Macro: GetTime <== Obsolete in SAS9.2            |
 |         GetInterval <== Current for SAS9.2        |
 |         GetIntervalTI <== Experimental for SAS9.2 |
 |                           using PROC TIMEID       |
 |                           (experimental)          |
 +---------------------------------------------------+
 |  Determine the time interval for a given          |
 |  equally spaced time series dataset.              |
\*---------------------------------------------------*/
%macro GetIntervalTI(DSName,TimeVar);
   %local TempData NullData;
   %let TempData=work.r%sysfunc(round(10000000*%sysfunc(ranuni(0))));
   %let NullData=&TempData.N;
   proc timeid data=&DSName outinterval=&TempData outfreq=&NullData;
      id &TimeVar;
   run;  
   data _null_;
      set &TempData;
      call symput("TimeInt",INTERVAL);
      call symput("SeasonalPeriod",SEASONALITY);
   run;
   %DeleteDS(&TempData);
   %DeleteDS(&NullData);
%mend GetIntervalTI;
%macro GetInterval(DSName,TimeVar);
   /*----  INTGET sometimes fails internally  ----*/
   data _null_;
      call symput("TimeInt","ERROR");
      call symput("SeasonalPeriod",9999999);
   run;
   data _null_;
      attrib IntName length=$16
             NewName length=$16;
      array DateVals{*} DV1-DV3;
      retain ObsNum 0 DV1 DV2 DV3 . IntName ' ' DiffInt 0;
      set &DSName(keep=&TimeVar) end=lastobs;
      if (&TimeVar>.Z) then ObsNum+1;
      StopIt=lastobs;
      if (1<=ObsNum<=2) then do;
         DateVals[ObsNum]=&TimeVar;
      end;
      else if (ObsNum=3) then do;
         DateVals[ObsNum]=&TimeVar;
         IntName=intget(DV1,DV2,DV3);
         if ((DV2-DV1) ^= (DV3-DV2)) then do;
            DiffInt=1;
         end;
      end;
      else if (ObsNum>3) then do;
         DV1=DV2;
         DV2=DV3;
         DV3=&TimeVar;
         NewName=intget(DV1,DV2,DV3);
         if ((DV2-DV1) ^= (DV3-DV2)) then do;
            DiffInt+1;
         end;
         if (length(IntName)<=1) or (strip(IntName)^=strip(NewName)) then do;
            StopIt=1;
            IntName="ERROR";
         end; 
      end;
      if (StopIt) then do;
         if (IntName="ERROR") then do;
            put "ERROR: Unequally spaced data found in &DSName";
            call symput("TimeInt","ERROR");
            call symput("SeasonalPeriod",9999999);
         end;
         else do;
            if (upcase(IntName)='DAY') and (DiffInt>1) then IntName='WEEKDAY';
            P=intseas(IntName);
            call symput("TimeInt",IntName);
            call symputx("SeasonalPeriod",P);
            put "NOTE: Time Interval = " IntName;
            put "NOTE: Seasonal Period = " P;
         end;
         stop;
      end;
   run;
%mend GetInterval;

%macro CheckInterval(DSName,TimeVar,IntervalName);
   data _null_;
      set &DSName end=lastobs;
      retain ObsNum 0 DV1 DV2 . IntName ' ' DiffInt 0;
      set &DSName(keep=&TimeVar) end=lastobs;
      if (&TimeVar>.Z) then ObsNum+1;
      StopIt=lastobs;
      if (ObsNum=1) then do;
         DV1=&TimeVar;
      end;
      else if (ObsNum=2) then do;
         DV2=&TimeVar;
         TestDate=intnx("&IntervalName",DV1,1);
         if (TestDate^=DV2) then do;
            DiffInt+1;
         end;
      end;
      else if (ObsNum>=3) then do;
         DV1=DV2;
         DV2=&TimeVar;
         TestDate=intnx("&IntervalName",DV1,1);
         if (TestDate^=DV2) then do;
            DiffInt+1;
         end;
      end;
      if (lastobs) then do;
         if (DiffInt=0) then do;
            put "NOTE: Data set &DSName has equally spaced dates for date variable &TimeVar (Interval=&IntervalName).";
         end;
         else do;
            put "ERROR: Data set &DSName does not have equally spaced dates for date variable &TimeVar (Interval=&IntervalName).";
         end;
      end;
   run;

%mend CheckInterval;

/*------------------------------------------------*\
 |  Macro: GetTime <== Obsolete in SAS9.2         |
 |         GetInterval <== Current for SAS9.2     |
 +------------------------------------------------+
 |  Determine the time interval for a given       |
 |  equally spaced time series dataset.           |
\*------------------------------------------------*/
%macro GetTime(DSName,TimeVar);
   data _null_;
      set &DSName(keep=&TimeVar) end=lastobs;
      retain MinuteCheck HourCheck DayCheck WeekdayCheck
             WeekCheck MonthCheck QuarterCheck YearCheck 1
             DTflag 0 ObsNum 0 LastTime 0;
      ObsNum+1;
      if (ObsNum=1) then do;
         LastTime=&TimeVar;
         if ('01JAN1800'd<=&TimeVar<='31DEC2010'd) then do;
            put "NOTE: (GetTime) &TimeVar is a SAS DATE variable.";
            MinuteCheck=0;
            HourCheck=0;
         end;
         else if ('00:00:00.0't<=&TimeVar<='24:00:00.0't) then do;
            put "NOTE: (GetTime) &TimeVar is a SAS TIME variable.";
            DayCheck=0;
            WeekCheck=0; 
            MonthCheck=0; 
            QuarterCheck=0; 
            YearCheck=0;
         end;
         else do;
            put "NOTE: (GetTime) &TimeVar is a SAS DATETIME variable.";
            DTflag=1;
         end;
      end;
      else do;
         if (MinuteCheck=1) and (DTflag=0) then do;
            MinuteCheck=intck('minute',LastTime,&TimeVar);
         end;
         else if (MinuteCheck=1) and (DTflag=1) then do;
            MinuteCheck=intck('dtminute',LastTime,&TimeVar);
         end;
         if (HourCheck=1) and (DTflag=0) then do;
            HourCheck=intck('hour',LastTime,&TimeVar);
         end;
         else if (HourCheck=1) and (DTflag=1) then do;
            HourCheck=intck('dthour',LastTime,&TimeVar);
         end;
         if (DayCheck=1) and (DTflag=0) then do;
            DayCheck=intck('day',LastTime,&TimeVar);
         end;
         else if (DayCheck=1) and (DTflag=1) then do;
            DayCheck=intck('dtday',LastTime,&TimeVar);
         end;
         if (WeekdayCheck=1) and (DTflag=0) then do;
            WeekdayCheck=intck('weekday',LastTime,&TimeVar);
         end;
         else if (WeekdayCheck=1) and (DTflag=1) then do;
            WeekdayCheck=intck('dtweekday',LastTime,&TimeVar);
         end;
         if (WeekCheck=1) and (DTflag=0) then do;
            WeekCheck=intck('week',LastTime,&TimeVar);
         end;
         else if (WeekCheck=1) and (DTflag=1) then do;
            WeekCheck=intck('dtweek',LastTime,&TimeVar);
         end;
         if (MonthCheck=1) and (DTflag=0) then do;
            MonthCheck=intck('month',LastTime,&TimeVar);
         end;
         else if (MonthCheck=1) and (DTflag=1) then do;
            MonthCheck=intck('dtmonth',LastTime,&TimeVar);
         end;
         if (QuarterCheck=1) and (DTflag=0) then do;
            QuarterCheck=intck('qtr',LastTime,&TimeVar);
         end;
         else if (QuarterCheck=1) and (DTflag=1) then do;
            QuarterCheck=intck('dtqtr',LastTime,&TimeVar);
         end;
         if (YearCheck=1) and (DTflag=0) then do;
            YearCheck=intck('year',LastTime,&TimeVar);
         end;
         else if (YearCheck=1) and (DTflag=1) then do;
            YearCheck=intck('dtyear',LastTime,&TimeVar);
         end;
         LastTime=&TimeVar;
      end;
      if (lastobs) then do;
         if (MinuteCheck=1) then do;
            call symput("TimeInt","MINUTE");
            call symput("SeasonalPeriod","1440");
         end;
         else if (HourCheck=1) then do;
            call symput("TimeInt","HOUR");
            call symput("SeasonalPeriod","24");
         end;
         else if (DayCheck=1) then do;
            call symput("TimeInt","DAY");
            call symput("SeasonalPeriod","7");
         end;
         else if (WeekCheck=1) then do;
            call symput("TimeInt","WEEK");
            call symput("SeasonalPeriod","52");
         end;
         else if (MonthCheck=1) then do;
            call symput("TimeInt","MONTH");
            call symput("SeasonalPeriod","12");
         end;
         else if (QuarterCheck=1) then do;
            call symput("TimeInt","QUARTER");
            call symput("SeasonalPeriod","4");
         end;
         else if (YearCheck=1) then do;
            call symput("TimeInt","YEAR");
            call symput("SeasonalPeriod","1");
         end; 
         else do;
            call symput("TimeInt","UNKNOWN");
         end;
      end;
   run;
   %if ("&TimeInt" ne "UNKNOWN") %then %do;
      %put NOTE: (GetTime) &TimeVar has time interval &TimeInt;
      %put NOTE: (GetTime) &TimeVar has default seasonal period &SeasonalPeriod;
   %end;
   %else %do;
      %put WARNING: (GetTime) &TimeVar may not be equally spaced;
   %end;
%mend GetTime;

/*------------------------------------------------*\
 |  Macro: DisplayDF                              |
 +------------------------------------------------+
 |  Display Augmented Dickey-Fuller results       |
 |  dropping the F-statistic and eliminating      |
 |  the zero mean test. Uses HTML output.         |
 |  Samples:                                      |
 |                                                |
 |  %DisplayDF(DSName=MyLib.MyData,TargetVar=Y);  |
 |  %DisplayDF(DSName=MyLib.MyData,TargetVar=Y,   |
 |             DifList=1 12);                     |
 |  %DisplayDF(DSName=MyLib.MyData,TargetVar=Y,   |
 |             Lag=3);                            |
 |  %DisplayDF(DSName=MyLib.MyData,TargetVar=Y,   |
 |             DifList=1,Lag=6,SLag=12);          |
 |  %DisplayDF(DSName=MyLib.MyData,TargetVar=y);  |
 |             Lag=6,SLag=4);                     |
\*------------------------------------------------*/
%macro DisplayDF(DSName=,TargetVar=,DifList=,Lag=5,SLag=0,ZeroMean=0);
   %let TempData=%RandWorkData();
   %let OutputList=%RanWinFile(Suffix=lst);
   filename ListFile "&OutputList";
   proc printto print=ListFile;
   run;
   ods select StationarityTests;
   ods output StationarityTests=&TempData;
   proc arima data=&DSName;
      %if ("&DifList" eq "") %then %do;
      identify var=&TargetVar 
      %end;
      %else %do;
      identify var=&TargetVar(&DifList)
      %end;
      %if ("&SLag" eq "0") %then %do;
               stationarity=(adf=(%ListDigits(&Lag)));
      %end;
      %else %do;
               stationarity=(adf=(%ListDigits(&Lag)) dlag=&SLag);
      %end;
   quit;
   ods output close;
   proc printto;
   run;
   data &TempData;
      set &TempData;
      %if (&Zeromean eq 0) %then %do;
      if (Type="Zero Mean") then delete;
      %end;
      drop FValue ProbF;
   run;

   %global HFlag;
   %IsODS_HTML(HFlag);

   %if (&HFlag) %then %do;
      proc print data=&TempData noobs label;
         var Type Lags Rho ProbRho Tau ProbTau;
      run;
   %end;
   %else %do;
      ods html;
      proc print data=&TempData noobs label;
         var Type Lags Rho ProbRho Tau ProbTau;
      run;
      ods html close;
   %end;
   %symdel HFlag;
   %EraseFile(&OutputList);
   %DeleteDS(&TempData);
%mend DisplayDF;

/*------------------------------------------------*\
 |  Macro: DisplayDFplot                          |
 +------------------------------------------------+
 |  Display and plot Augmented Dickey-Fuller      |
 |  results dropping the F-statistic and          |
 |  eliminating the zero mean test.               |
 |  Uses HTML output if called appropriately.     |
 |  Samples:                                      |
 |                                                |
 |  ods html;                                     |
 |  %DisplayDFplot(DSName=MyLib.MyData,           |
 |                 TargetVar=Y);                  |
 |  ods html close;                               |
 |                                                |
 |  %DisplayDFplot(DSName=MyLib.MyData,           |
 |                 TargetVar=Y,                   |
 |                 DifList=1 12);                 |
 |  %DisplayDFplot(DSName=MyLib.MyData,           |
 |                 TargetVar=Y,                   |
 |                 Lag=3);                        |
 |  %DisplayDFplot(DSName=MyLib.MyData,           |
 |                 TargetVar=Y,                   |
 |                 DifList=1,Lag=6,SLag=12);      |
 |  %DisplayDFplot(DSName=MyLib.MyData,           |
 |                 TargetVar=y);                  |
 |                 Lag=6,SLag=4);                 |
\*------------------------------------------------*/
%macro DisplayDFplot(DSName=,TargetVar=,DifList=,Lag=5,SLag=0,
                     ZeroMean=0,SingleMean=1,TrendTest=1);
   %if (%eval(&ZeroMean+&SingleMean+&TrendTest) eq 0) %then %do;
      %put ERROR: In macro DisplayDFPlot, no tests requested.;
   %end;
   %else %do;
   %let TempData=%RandWorkData();

   ods select StationarityTests;
   ods output StationarityTests=&TempData;
   proc arima data=&DSName;
      %if ("&DifList" eq "") %then %do;
      identify var=&TargetVar 
      %end;
      %else %do;
      identify var=&TargetVar(&DifList)
      %end;
      %if ("&SLag" eq "0") %then %do;
               stationarity=(adf=(%ListDigits(&Lag)));
      %end;
      %else %do;
               stationarity=(adf=(%ListDigits(&Lag)) dlag=&SLag);
      %end;
   quit;
   ods output close;

   data &TempData;
      set &TempData;
      %if (&ZeroMean eq 0) %then %do;
      if (Type="Zero Mean") then delete;
      %end;
      %if (&SingleMean eq 0) %then %do;
      if (Type="Single Mean") then delete;
      %end;
      %if (&TrendTest eq 0) %then %do;
      if (Type="Trend") then delete;
      %end;
      %if (&SLag eq 0) %then %do;
      drop FValue ProbF;
      %end;
      format ProbRho ProbTau 6.4;
   run;

   proc print data=&TempData noobs label;
      var Type Lags Rho ProbRho Tau ProbTau;
   run;

   %if (%ODSOK()) %then %do;
      data &TempData;
         set &TempData;
         PValue=round(1-log10(ProbTau),0.0001);
      run;
      %if (&ZeroMean ne 0) %then %do;
      proc sgplot data=&TempData(where=(Type="Zero Mean"));
         vbar Lags / Response=PValue;
         refline 2 / axis=y
            lineattrs=GraphPrediction(pattern=1 color=green)
            legendlabel="p=0.1" name="series0";;
         refline 2.301 / axis=y
            lineattrs=GraphPrediction(pattern=4 color=green)
            legendlabel="p=0.05" name="series1";
         refline 3 / axis=y
            lineattrs=GraphPrediction(pattern=2 color=green)
            legendlabel="p=0.01" name="series2";
         yaxis min=1 max=3.2 display=(noline noticks novalues)
            label="1-(Prob>Tau)";
         keylegend "series0" "series1" "series2" /
            title="Zero Mean Test" 
            location=outside position=bottom; 
      run;
      %end;

      %if (&SingleMean ne 0) %then %do;
      proc sgplot data=&TempData(where=(Type="Single Mean"));
         vbar Lags / Response=PValue;
         refline 2 / axis=y
            lineattrs=GraphPrediction(pattern=1 color=green)
            legendlabel="p=0.1" name="series0";;
         refline 2.301 / axis=y
            lineattrs=GraphPrediction(pattern=4 color=green)
            legendlabel="p=0.05" name="series1";
         refline 3 / axis=y
            lineattrs=GraphPrediction(pattern=2 color=green)
            legendlabel="p=0.01" name="series2";
         yaxis min=1 max=3.2 display=(noline noticks novalues)
            label="1-(Prob>Tau)";
         keylegend "series0" "series1" "series2" /
            title="Single Mean Test" 
            location=outside position=bottom; 
      run;
      %end;
      %if (&SLag eq 0) and (&TrendTest ne 0) %then %do;
      proc sgplot data=&TempData(where=(Type="Trend"));
         vbar Lags / Response=PValue;
         refline 2 / axis=y
            lineattrs=GraphPrediction(pattern=1 color=green)
            legendlabel="p=0.1" name="series0";;
         refline 2.301 / axis=y
            lineattrs=GraphPrediction(pattern=4 color=green)
            legendlabel="p=0.05" name="series1";
         refline 3 / axis=y
            lineattrs=GraphPrediction(pattern=2 color=green)
            legendlabel="p=0.01" name="series2";
         yaxis min=1 max=3.2 display=(noline noticks novalues)
            label="1-(Prob>Tau)";
         keylegend "series0" "series1" "series2" /
            title="Trend Test" 
            location=outside position=bottom; 
      run;
      %end;
   %end;
   %else %do;
      %put ERROR: In macro DisplayDFplot, plots are not available in this release of SAS.;
   %end;

   %DeleteDS(&TempData);
   %end;
%mend DisplayDFplot;

/*------------------------------------------------*\
 |  Macro: DisplayOrders                          |
 +------------------------------------------------+
 |  Display orders (p,q) selected by ESACF,       |
 |  SCAN, and MINIC.                              |
 |  Samples:                                      |
 |                                                |
 |  %DisplayOrders(DSName=MyLib.MyData,           |
 |                 TargetVar=Y);                  |
 |  %DisplayOrders(DSName=MyLib.MyData,           |
 |                 TargetVar=Y,DifList=1 12);     |
 |  %DisplayOrders(DSName=MyLib.MyData,           |
 |                 TargetVar=Y,MaxLag=3);         |
 |  %DisplayOrders(DSName=MyLib.MyData,           |
 |                 TargetVar=Y,DifList=1,         |
 |                 MaxLag=6);                     |
 |  %DisplayOrders(DSName=MyLib.MyData,           |
 |                 TargetVar=y,MaxLag=6);         |
\*------------------------------------------------*/
%macro DisplayOrders(DSName=,TargetVar=,DifList=,MaxLag=5);
   %let TempData=%RandWorkData();
   %let OutputList=%RanWinFile(Suffix=lst);
   filename ListFile "&OutputList";
   proc printto print=ListFile;
   run;
   ods select TentativeOrders;
   ods output TentativeOrders=&TempData;
   proc arima data=&DSName;
      %if ("&DifList" eq "") %then %do;
      identify var=&TargetVar 
      %end;
      %else %do;
      identify var=&TargetVar(&DifList)
      %end;
               esacf minic scan p=(0:&MaxLag) q=(0:&MaxLag)
               perror=(3:%eval(2*&MaxLag+2));
   quit;
   ods output close;
   proc printto;
   run;
   data &TempData;
      set &TempData;
      if (index(SCAN_AR,'_')>0) then SCAN_AR=' ';
      if (index(SCAN_MA,'_')>0) then SCAN_MA=' ';
      if (index(SCAN_IC,'_')>0) then SCAN_IC=' ';
      if (index(ESACF_AR,'_')>0) then ESACF_AR=' ';
      if (index(ESACF_MA,'_')>0) then ESACF_MA=' ';
      if (index(ESACF_IC,'_')>0) then ESACF_IC=' ';
      label SCAN_AR='SCAN p+d'
            SCAN_MA='SCAN q'
            SCAN_IC='SCAN BIC'
            ESACF_AR='ESACF p+d'
            ESACF_MA='ESACF q'
            ESACF_IC='ESACF BIC';
   run;
   %global HFlag;
   %IsODS_HTML(HFlag);

   %if (&HFlag) %then %do;
      proc print data=&TempData noobs split=' ';
         var SCAN_AR SCAN_MA SCAN_IC ESACF_AR ESACF_MA ESACF_IC;
      run;
   %end;
   %else %do;
      ods html;
      proc print data=&TempData noobs split=' ';
         var SCAN_AR SCAN_MA SCAN_IC ESACF_AR ESACF_MA ESACF_IC;
      run;
      ods html close;
   %end;
   %symdel HFlag;
   %EraseFile(&OutputList);
   %DeleteDS(&TempData);
%mend DisplayOrders;

/*----  Patterns in ESACF (SEACF) based on ----*/
/*----  Pena, Tiao, and Tsay: A Course in  ----*/
/*----  Time Series Analysis.              ----*/
/*------------------------------------------------*\
 |  Macro: VisualizeESACF                         |
 +------------------------------------------------+
 |  Patterns in ESACF (SEACF) based on            |
 |  Pena, Tiao, and Tsay: A Course in             |
 |  Time Series Analysis.                         |
 |                                                |
 |  ods output ESACFPValues=work.esacfp;          |
 |  proc arima data=sasuser.armaexamples;         |
 |     identify var=Y7 nlags=14                   |
 |              esacf minic scan                  |
 |              P=(0:10) Q=(0:10)                 | 
 |              PERROR=(3:12);                    |
 |  quit;                                         |
 |                                                |
 |  %VisualizeESACF(DSName=MyLib.MyData,          |
 |                  OutDS=work.esacfvis);         |
 |  %VisualizeESACF(DSName=MyLib.MyData,          |
 |                  OutDS=work.esacfvis,          |
 |                  SymbolHigh=1,SymbolLow=0);    |
\*------------------------------------------------*/
%macro VisualizeESACF(DSName=,OutDS=,CutOff=0.05,SymbolHigh=+,SymbolLow=.);
   %local CheckSym;
   data _null_;
      attrib Check length=$2;
      Okay=1;
      Check="&SymbolHigh";
      if (length(Check)^=1) then do;
         Okay=0;
         put "ERROR: In macro VisualizeESACF, high symbol is &SymbolHigh (must be length=1).";
      end;
      Check="&SymbolLow";
      if (length(Check)^=1) then do;
         Okay=0;
         put "ERROR: In macro VisualizeESACF, low symbol is &SymbolLow (must be length=1).";
      end;
      if (Okay=0) then do;
         call symput('CheckSym','N');
      end;
      else do;
         call symput('CheckSym','Y');
      end;
   run;
   %if (&CheckSym eq Y) %then %do;
      %let NumCol=%eval(%GetNumVars(&DSName) - 1);
      %let MaxMA=%eval(&NumCol-1);
      %let NumRow=%GetNumObs(&DSName);
      %if (&NumCol>0) & (&NumRow>0) %then %do;
         data &OutDS;
            set &DSName;
            attrib SMA_0-SMA_&MaxMA length=$1;
            %if (%sysevalf(&MaxMA>9) eq 1) %then %do;
            array MAA{*} MA__0-MA__9 MA_10-MA_&MaxMA;
            %end;
            %else %do;
            array MAA{*} MA_0-MA_&MaxMA;
            %end;
            array SMAA{*} SMA_0-SMA_&MaxMA;
            do index=1 to &NumCol;
               if MAA[index]>&CutOff then SMAA[index]="&SymbolHigh";
               else SMAA[index]="&SymbolLow";
            end;
            %if (%sysevalf(&MaxMA>9) eq 1) %then %do;
            drop index MA__0-MA__9 MA_10-MA_&MaxMA;
            %end;
            %else %do;
            drop index MA_0-MA_&MaxMA;
            %end;
            rename SMA_0=MA_0
            %do order=1 %to &MaxMA;
                   SMA_&order = MA_&order
            %end;
                   RowName=Orders;
         run; 
      %end;
   %end;
%mend VisualizeEsacf;


/*---------------------------------------------*\
 |  Macro: ARIMAHoldout                        |
 +---------------------------------------------+
 |  Pick best ARMA model based on RMSE or MAPE |
 |  using a holdout sample and one-step ahead  |
 |  forecasts.                                 |
\*---------------------------------------------*/
%macro ARIMAHoldout(DSName=,TargetVar=,Holdout=,
                    IdString=,EstString=,OutData=);
   /*----  Set up temporary Data  ----*/
   %let Tempfore=%RandWorkData();
   %let TempAll=&Tempfore.ALL;
   %let TempInput=&Tempfore.INP;
   %let TempModel=&Tempfore.MOD;
   %let TempStat=&Tempfore.ST;
   %let HoldVar=%RandVarName();
   
   %let Cutoff=%eval(%GetNumObs(&DSName) - &Holdout);
   data &TempInput;
      set &DSName;
      retain ObsNo 0;
      ObsNo+1;
      if (ObsNo>&Cutoff) then &HoldVar=.;
      else &HoldVar=&TargetVar;
      drop ObsNo;
   run;

   proc arima data=&TempInput;
      identify &IdString noprint;
      estimate &EstString 
               outmodel=&TempModel 
               outstat=&TempStat
               noprint;
   quit;
   proc sql noprint;
      select _VALUE_ into :NumParms
      from &TempStat
      where (_STAT_='NPARMS');
   quit;

   data &TempModel;
      attrib _NAME_ length=$32;
      set &TempModel(rename=(_NAME_=_NEWNAME_));
      if (_NEWNAME_="&HoldVar") then _NAME_="&TargetVar";
      else _NAME_=_NEWNAME_;
      drop _NEWNAME_;
   run;

   %ArimaNoest(&TempInput,&TempModel,&Tempfore);

   data &TempInput &Tempfore;
      set &Tempfore;
      retain ObsNo 0;
      ObsNo+1;
      if (ObsNo > &Cutoff) then output &TempInput;
      else output &Tempfore;
      keep &TargetVar FORECAST;
   run;

   %global MAPE RMSE AIC_SSE SBC_SSE;
   %GetGOF(DSName=&Tempfore,ActualVar=&TargetVar,
           ForeVar=FORECAST,NumParm=&NumParms);

   data &TempAll;
      attrib Source length=$16;
      Source='Fit Sample';
      RMSE=&RMSE;
      MAPE=&MAPE;
      AIC_SSE=&AIC_SSE;
      SBC_SSE=&SBC_SSE;
      output;
   run;

   %GetGOF(DSName=&TempInput,ActualVar=&TargetVar,
           ForeVar=FORECAST,NumParm=&NumParms);

   data &TempAll;
      set &TempAll end=lastobs;
      output;
      if (lastobs) then do;
         Source='Holdout Sample';
         RMSE=&RMSE;
         MAPE=&MAPE;
         AIC_SSE=&AIC_SSE;
         SBC_SSE=&SBC_SSE;
         output;
      end;
   run;

   %if (&OutData ne) %then %do;
      data &OutData;
         set &TempAll;
      run;
   %end;
   %DeleteDS(&Tempfore);
   %DeleteDS(&TempAll);
   %DeleteDS(&TempInput);
   %DeleteDS(&TempModel);
   %DeleteDS(&TempStat);
%mend ARIMAHoldout;

/*---------------------------------------------*\
 |  Macro: BestCCF                             |
 +---------------------------------------------+
 |  Purpose: Return a data set having the      |
 |           largest CCF value for each input, |
 |           whether or not the CCF value      |
 |           is significant, and then all      |
 |           additional CCF values that are    |
 |           significant.                      |
 |           The returned data set has         |
 |           variables MaxFlag and SigFlag.    |
 |           MaxFlag=1 for the largest CCF,    |
 |           0 otherwise. SigFlag=1 for all    |
 |           observations where MaxFlag=0,     |
 |           but SigFlag may be 0 when MaxFlag |
 |           is 1. Thus, selecting observations|
 |           with SigFlag=0 will return inputs |
 |           that probably should be excluded  |
 |           from further analysis.            |
 +---------------------------------------------+
 |  Usage:                                     |
 |  %BestCCF(DSName=SAS-data-set-name,         |
 |           OutDS=SAS-data-set-name,          |
 |           TargetVar=variable-name,          |
 |           InputVars=variable1 variable2 ...,|
 |           DifLags=positive-integers,        |
 |           MaxLags=positive-integers);       |
 +---------------------------------------------+
 |  Example:                                   |
 |  %BestCCF(DSName=MyLib.MyDataSet,           |
 |           OutDS=work.AnalysisCCF,           |
 |           TargetVar=WidgetsSold,            |
 |           InputVars=Promotions Price Jul4,  |
 |           DifLags=1 12,                     |
 |           MaxLags=12);                      |
 +---------------------------------------------+
 |  Univariate screening approach to variable  |
 |  selection with some dynamic features.      |
 |  The ouput data set contains the significant|
 |  crosscorrelation values along with the     |
 |  value of the largest crosscorrelation      |
 |  even if it is not significant. A cutoff    |
 |  of 1.645 is used to determine significance.|
 |  Differencing is applied to the target and  |
 |  all inputs.                                |
\*---------------------------------------------*/
%macro BestCCF(DSName=,OutDS=,TargetVar=,InputVars=,DifLags=,MaxLags=24);
   %let TempData=%RandWorkData();
   %let TermFlag=0;
   %let NumObs=%GetNumObs(&DSName);
   %if (&NumObs eq 0) %then %do;
      %put ERROR: In macro BestCCF, data set &DSName not found.;
      %let TermFlag=1;
   %end;
   %else %do;
      %if (%GetVarType(&DSName,&TargetVar) eq 0) %then %do;
         %put ERROR: In macro BestCCF, variable &TargetVar not found in data set &DSName.;
         %let TermFlag=1;
      %end;
      %let NumInputs=%NumberWords(&InputVars,%str( ));
      %do _i_=1 %to &NumInputs;
         %let InpVar = %scan(&InputVars,&_i_,%str( ));
         %if( %GetVarType(&DSName,&InpVar) eq 0) %then %do;
            %put ERROR: In macro BestCCF, variable &InpVar not found in data set &DSName.;
            %let TermFlag=1;
         %end;
      %end;
   %end;
   %if (&TermFlag eq 0) %then %do;
      %if (&DifLags eq) %then %do;
         %let DifLags=0;
      %end;
      %let NumLags=%eval(&NumObs/4);
      %if (&NumLags lt 6) %then %do;
         %let NumLags=6;
      %end;
      %else %if (&NumLags gt &MaxLags) %then %do;
         %let NumLags=&MaxLags;
      %end;
      %put NumObs= &NumObs NumLags= &NumLags;
      proc arima data=&DSName;
         identify var=&TargetVar(&DifLags) 
      %if (&DifLags eq 0) %then %do;
                  crosscorr=(&InputVars)
      %end;
      %else %do;
                  crosscorr=(
         %do _i_=1 %to &NumInputs;
            %let InpVar = %scan(&InputVars,&_i_,%str( ));
                  &InpVar(&DifLags)
         %end;
                  )
      %end;
                  nlags=&NumLags
                  outcov=&TempData noprint;
      run;
      quit;
      data &TempData;
         set &TempData;
         if (CROSSVAR eq '') or (Lag<0) then delete;
         EvalCorr=abs(CORR);
         if (EvalCorr>1.645*STDERR) then SigFlag=1;
         else SigFlag=0;
         keep LAG CROSSVAR N CORR STDERR EvalCorr SigFlag;
      run;
      proc sort data=&TempData;
         by CROSSVAR descending EvalCorr;
      run;
      data &OutDS;
         set &TempData;
         by CROSSVAR;
         if (first.CROSSVAR) then do;
            MaxFlag=1;
            output;
         end;
         else if (SigFlag=1) then do;
            MaxFlag=0;
            output;
         end;
         keep LAG CROSSVAR N CORR STDERR SigFlag MaxFlag;
      run;
      %DeleteDS(&TempData);
   %end;
%mend BestCCF;


%put ForecastUtilityMacros.sas Loaded;

/*------------------*\
 |  End of program  |
\*------------------*/

/*----------------------------------------------------*\
 |                                                    |
 |   Copyright (c) 2011 SAS Institute, Inc.           |
 |   Cary, N.C. USA 27513-8000                        |
 |   all rights reserved                              |
 |                                                    |
 |   THIS PROGRAM IS PROVIDED BY THE INSTITUTE "AS IS"|
 |   WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR|
 |   IMPLIED, INCLUDING BUT NOT LIMITED TO THE        |
 |   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS|
 |   FOR A PARTICULAR PURPOSE.  RECIPIENTS ACKNOWLEDGE|
 |   AND AGREE THAT THE INSTITUTE SHALL NOT BE LIABLE |
 |   WHATSOEVER FOR ANY DAMAGES ARISING OUT OF THEIR  |
 |   USE OF THIS PROGRAM.                             |
 |                                                    |
\*----------------------------------------------------*/
/*----------------------------------------------------*\
 |              S A S    T R A I N I N G              |
 |                                                    |
 |    NAME: ForecastPlotMacros.sas                    |
 |   TITLE: Macros for Plotting Time Series and       |
 |          Related Functions and Data                |
 |  SYSTEM: ALL (Windows pathname)                    |
 |    KEYS:                                           |
 |  COURSE: All                                       |
 |    DATA: None                                      |
 |                                                    |
 | SUPPORT: TJW                    UPDATE: 13MAY2009  |
 |     REF:                                           |
 |    MISC: SAS9.2 or later required                  |
 |                                                    |
 |----------------------------------------------------|
 |   NOTES                                            |
 |                                                    |
 |   These macros were created to support SAS         |
 |   training. Macros can be incoprorated into SAS    |
 |   programs in several ways. For training purposes, |
 |   the macros are typically compiled as part of     |
 |   initialization code designed for the training.   |
 |   The usual strategy is for the course with code   |
 |   FXYZ to have an associated SAS file FXYZ.sas     |
 |   that includes the statement:                     |
 |                                                    |
 |   %include "<folder>/ForecastPlotMacros.sas";      |
 |                                                    |
 |   where <folder> is the location of course SAS     |
 |   programs.                                        |
 |                                                    |
 |   Other strategies for macro compiling, storage,   |
 |   and access are possible.                         |
\*----------------------------------------------------*/

/*----  Setup  ----*/
%macro GraphOutput(Choice=activex,PlotName=Default);
   %if ("%upcase(&Choice)" eq "BMP") %then %do;
      filename grafout "&PROJSASDIR\&PlotName..bmp";
      goptions device=bmp gsfname=grafout gsfmode=replace display;
      goptions hsize=8in vsize=5in noborder;
   %end;
   %else %if ("%upcase(&Choice)" eq "JPG") %then %do;
      filename grafout "&PROJSASDIR\&PlotName..jpg";
      goptions device=jpg gsfname=grafout gsfmode=replace display;
      goptions hsize=8in vsize=5in noborder;
   %end;
   %else %if ("%upcase(&Choice)" eq "GIF") %then %do;
      filename grafout "&PROJSASDIR\&PlotName..gif";
      goptions device=gif gsfname=grafout gsfmode=replace display;
      goptions hsize=8in vsize=5in noborder;
   %end;
   %else %if ("%upcase(&Choice)" eq "PNG") %then %do;
      filename grafout "&PROJSASDIR\&PlotName..png";
      goptions device=png gsfname=grafout gsfmode=replace display;
      goptions hsize=8in vsize=5in noborder;
   %end;
   %else %if ("%upcase(&Choice)" eq "PNG300") %then %do;
      filename grafout "&PROJSASDIR\&PlotName._300.png";
      goptions device=png gsfname=grafout gsfmode=replace display;
      goptions hsize=8in vsize=5in noborder;
   %end;
   %else %do;
      goptions device=activex;
   %end;
%mend GraphOutput;

%macro ODSOK();
   %sysevalf(%substr(&SYSVER,1,3) ge 9.2,boolean)
%mend ODSOK;

%macro ODSPLOTS(ProcName);
   %if (%ODSOK()) %then %do;
      %if ("%upcase(&ProcName)" eq "ARIMAALL") %then %do;
         plots=(residual(smooth) forecast(forecast))
      %end;
      %if ("%upcase(&ProcName)" eq "ARIMA") %then %do;
         plots(only)=(forecast(forecast))
      %end;
      %else %if ("%upcase(&ProcName)" eq "UCM") %then %do;
         plots=all
      %end;
   %end;
%mend ODSPLOTS;

/*----------------------------------------*\
  ----------------------------------------
  ----------------------------------------
  ----  Plot Original Series Section  ----
  ----------------------------------------
  ----------------------------------------
\*----------------------------------------*/

/*----------------------------------------------*\
 |  Macro: PlotTimeSeries                       |
 +----------------------------------------------+
 |  Plot original series using PROC TIMESERIES  |
\*----------------------------------------------*/
%macro PlotTimeSeries(DSName=,TargetVar=,
                      DateVar=Date,
                      IntervalName=NULL);
%if %sysfunc(exist(&DSName)) %then %do;
   %if ("%GetVarType(&DSName,&TargetVar)" eq "N") %then %do;
   %let TempData=%RandWorkData();

   proc timeseries data=&DSName 
                   out=&TempData
                   print=(summary)
                   plot=(series);
      var &TargetVar;
      %if ("&IntervalName" ne "NULL") %then %do;
      id &DateVar interval=&IntervalName;
      %end;
   run;

   %DeleteDS(&TempData);
   %end;
   %else %do;
      %put ERROR: In macro PlotTimeSeries, problem with variable &TargetVar in data set &DSName..;
   %end;
%end;
%else %do;
   %put ERROR: In macro PlotTimeSeries, cannot open &DSName..;
%end;
%mend PlotTimeSeries;

/*----------------------------------------------*\
 |  Macro: PlotTSForecast                       |
 +----------------------------------------------+
 |  Plot original series vs forecast.           |
\*----------------------------------------------*/
%macro PlotTSForecast(DSName=_LAST_,TargetVar=,
                      ForecastVar=,
                      DateVar=Date);
   %if (%ODSOK()) %then %do;

      proc sgplot data=&DSName; 
         scatter x=&DateVar y=&TargetVar;
         series  x=&DateVar y=&ForecastVar / 
                 lineattrs=GraphPrediction(pattern=1 color=darkblue)
                 legendlabel="Forecast" name="series";
         keylegend "series" / location=outside position=bottom;
      run;

   %end;
   %else %do;
      symbol1 color=BLACK
              interpol=none
              value=dot
              line=1
              width=2
              height=.5;
      symbol2 color=BLUE
              interpol=join
              value=circle
              line=1
              width=2
              height=.5;
      proc gplot data=&DSName;
         plot (&TargetVar &ForecastVar)*&DateVar/overlay;
      run;
      quit;
   %end;
%mend PlotTSForecast;

/*----------------------------------------------*\
 |  Macro: PlotSeries                           |
 +----------------------------------------------+
 |  Plot original series or actual vs forecast. |
 |  If Terse=YES, then symbol statements are    |
 |  defined in calling program.                 |
 |  If ForecastVar is blank, only original      |
 |  series is plotted.                          |
 |  NOTE: Essentially made obsolete by ODS      |
 |        statistical graphics.                 |
\*----------------------------------------------*/
%macro PlotSeries(DSName=_LAST_,TargetVar=,
                  ForecastVar=,
                  DateVar=Date,
                  ColorOne=BLACK,ColorTwo=BLUE,Terse=NO);
   %put NOTE: Consider using macro PlotTSForecast in place of PlotSeries.;
   %if ("%upcase(&Terse)" eq "NO") %then %do;
      symbol1 color=&ColorOne
              interpol=none
              value=dot
              line=1
              width=2
              height=.5;
      symbol2 color=&ColorTwo
              interpol=join
              value=circle
              line=1
              width=2
              height=.5;
      
   %end;
   %if ("&ForecastVar" eq "") %then %do;
      %if ("%upcase(&Terse)" eq "NO") %then %do;
      symbol1 interpol=join;
      %end;
      proc gplot data=&DSName;
         plot &TargetVar * &DateVar;
      run;
      quit;
   %end;
   %else %do;
      proc gplot data=&DSName;
         plot (&TargetVar &ForecastVar)*&DateVar/overlay;
      run;
      quit;
   %end;
%mend PlotSeries;

%macro PlotSeriesCompare(DSName=_LAST_,TargetVar=,
                         ForecastOne=,
                         ForecastTwo=,
                         DateVar=Date);
   %if (%ODSOK()) %then %do;

      proc sgplot data=&DSName; 
         scatter x=&DateVar y=&TargetVar; 
                 * / markerattrs=(color=black symbol=Plus);
         series  x=&DateVar y=&ForecastOne / 
                 lineattrs=GraphPrediction(pattern=2 color=blue)
                 legendlabel="&ForecastOne" name="series1";
         series  x=&DateVar y=&ForecastTwo / 
                 lineattrs=GraphPrediction(color=green)
                 legendlabel="&ForecastTwo" name="series2";
         keylegend "series1" "series2" / location=outside position=bottom;
      run;

   %end;
   %else %do;
      symbol1 color=BLACK
              interpol=none
              value=dot
              line=1
              width=2
              height=0.7;
      symbol2 color=BLUE
              interpol=join
              value=circle
              line=1
              width=2
              height=0.7;
      symbol3 color=GREEN
              interpol=join
              value=square
              line=1
              width=2
              height=0.7;
      
      legend1 label=(justify=center "Forecast Legend" position=(top center))
              value=(justify=left tick=1 "Actual" tick=2 "&ForecastOne"
                     tick=3 "&ForecastTwo")
              ;
      proc gplot data=&DSName;
         plot (&TargetVar &ForecastOne &ForecastTwo)*&DateVar/
               overlay legend=legend1;
      run;
      quit;
   %end;
%mend PlotSeriesCompare;

%macro PlotSmoothSeries(DSName=_LAST_,TargetVar=,
                        DateVar=Date,
                        Smoothness=20);
   %if (%ODSOK()) %then %do;
      %if ("&Smoothness" ne "20") %then %do;
      %put NOTE: Smoothness parameter is ignored when ODS graphics are available.;
      %end;

      proc sgplot data=&DSName;
         pbspline x=&DateVar y=&TargetVar;
      run;
      proc sgplot data=&DSName;
         loess x=&DateVar y=&TargetVar;
      run;

   %end;
   %else %do;
      symbol1 color=black
              interpol=none
              value=dot
              height=0.3
              line=1
              width=2;
      symbol2 color=blue
              interpol=sm&Smoothness
              value=none
              line=1
              width=2;
      proc gplot data=&DSName;
         plot (&TargetVar &TargetVar) * &DateVar/overlay;
      run;
      quit;
   %end;
%mend PlotSmoothSeries;

/*----------------------------------------------*\
 |  Macro: PlotSeriesCI                         |
 +----------------------------------------------+
 |  Plot series, forecasts, and confidence      |
 |  intervals.  If ODS Statistical Graphics is  |
 |  not available, assumes that symbol and axis |
 |  statements have been defined, with          |
 |  VAXIS=AXIS1 and HAXIS=AXIS2.                |
\*----------------------------------------------*/
%macro PlotSeriesCI(DSName=,TargetVar=,ForecastVar=,DateVar=,Start=);
   %if (%ODSOK()) %then %do;

      proc sgplot data=&DSName;
         band x=&DateVar lower=L95 upper=U95 /
              legendlabel="95% CI" name="band1"; 
         scatter x=&DateVar y=&TargetVar;
         series  x=&DateVar y=&ForecastVar / lineattrs=GraphPrediction
                 legendlabel="Forecast" name="series";
         refline &Start / axis=x; 
         keylegend "series" "band1" / location=outside position=bottom;
      run;

   %end;
   %else %do;
      proc gplot data=&DSName;
         plot (&TargetVar &ForecastVar L95 U95)*&DateVar/
              vaxis=axis1 haxis=axis2 overlay href=&Start;
      run;
      quit;
   %end;
%mend PlotSeriesCI;


/*----------------------------------------------------*\
 |  Macro: PlotResiduals                              |
 +----------------------------------------------------+
 |  Plot residuals with INTERPOL=NEEDLE option in the |
 |  symbol statement.                                 |
 |                                                    |
 |  ODS options and graphics options via GOPTIONS     |
 |  should be specified before calling this macro.    |
\*----------------------------------------------------*/
%macro PlotResiduals(DSName=_LAST_,TargetVar=,
                     ForecastVar=FORECAST,
                     DateVar=Date);
   %let TempResid=%RandWorkData();
   data &TempResid;
      set &DSName;
      Residual=&TargetVar-&ForecastVar;
      if (Residual=.) then delete;
      label Residual='Residuals';
   run;
   %if (%ODSOK()) %then %do;

      proc sgplot data=&TempResid;
         needle x=&DateVar y=Residual / 
                baseline=0
                lineattrs=(color=blue)
                markers
                markerattrs=(symbol=CircleFilled color=blue);
      run;

   %end;
   %else %do;
      symbol1 color=blue
              interpol=needle
              width=2
              value=none;

      proc gplot data=&TempResid;
         plot Residual*&DateVar/vref=0;
      run;
      quit;
   %end;
   %DeleteDS(&TempResid);
%mend PlotResiduals;

/*----------------------------------------------------*\
 |  Macro: PlotPiPsi                                  |
 +----------------------------------------------------+
 |  Plot PSI and PI weights.                          |
 |                                                    |
 |  PSI(B)=THETA(B)/PHI(B)                            |
 |                                                    |
 |  PI(B)=PHI(B)/THETA(B)                             |
 +----------------------------------------------------+
 |  EXAMPLE                                           |
 +----------------------------------------------------+
ods html;
%PlotPiPsi(1 0.9,1 -0.7,12);
ods html close;
\*----------------------------------------------------*/
%macro PlotPiPsi(ARLIST,MALIST,NLAGS);
   %if %sysprod(iml)=1 %then %do;
      %let TempWork=%RandWorkData();
      proc iml;
         Phi={&ARLIST};
         Theta={&MALIST};
         Psi=ratio(Phi,Theta,&NLAGS);
         Pi=ratio(Theta,Phi,&NLAGS);
         Lags=0:%eval(&NLAGS-1);
         Y=Lags`||Pi`||Psi`;
         oname={'Lags' 'Pi' 'Psi'};
         create &TempWork from Y[colname=oname];
         append from Y;
         close &TempWork;
      run;
      quit;
      %if (%ODSOK()) %then %do;

         proc sgplot data=&TempWork;
            vbar Lags / Response=Pi Stat=sum;
            refline 0 / axis=y;
         run;
         proc sgplot data=&TempWork;
            vbar Lags / Response=Psi Stat=sum;
            refline 0 / axis=y;
         run;

      %end;
      %else %do;
         axis1 label=("PI Weights") order=(-1 to 1 by 0.25);
         axis2 label=("PSI Weights") order=(-1 to 1 by 0.25);

         proc gchart data=&TempWork;
            /*----  Pi Weight Chart  ----*/
            vbar Lags / discrete
                        sumvar=Pi 
                        ref=0
                        raxis=axis1;
         run;
            /*----  Psi Weight Chart  ----*/
            vbar Lags / discrete 
                        sumvar=Psi 
                        ref=0 
                        raxis=axis2;
         run;
         quit;

         /*----  Uncomment for line plots  ----*\
         symbol1 color=Blue
                 interpol=join
                 value=dot
                 line=1
                 height=.5;
         symbol2 color=Red
                 interpol=join
                 value=square
                 line=2
                 height=.5;

         proc gplot data=&TempWork;
            plot Pi*Lags/vref=0 vaxis=axis1;
            plot Psi*Lags/vref=0 vaxis=axis2;
         run;
         quit;
         \*----  End of Line Plots  ----*/
      %end;
      %DeleteDS(&TempWork);
   %end;
   %else %do;
      %put ERROR: Macro PlotPiPsi requires SAS/IML.;
   %end;
%mend PlotPiPsi;

/*----------------------------------------------------*\
 |   Macro: PlotPsi                                   |
 +----------------------------------------------------+
 |   Plot transfer function PSI weights               |
 |                                                    |
 |   PSI(B)=w(B)/d(B)=h0-h1*B-h2*B**2-h3*B**3...      |
 |                                                    |
 |   coefficients of the truncated infinite           |
 |   polynomial                                       |
 +----------------------------------------------------+
 |  EXAMPLE                                           |
 +----------------------------------------------------+
ods html;
%PlotPsi(2,-0.9 0.15 -0.05,NLAGS=60);
ods html close;
\*----------------------------------------------------*/
%macro PlotPsi(NUMLIST,DENLIST,NLAGS=99,OutDS=);
   %if %sysprod(iml)=1 %then %do;
      %let TempWork=%RandWorkData();
      %let CUTOFF=0.01;
      proc iml;
         Phi={&NUMLIST};
         Theta={1 &DENLIST};
         Psi=ratio(Theta,Phi,&NLAGS);
         numLag=&NLAGS;      
         Lag=1:numLag;
         Psi=Psi[1,1:numLag];
         Y=Lag`||Psi`;
         oname={'Lag' 'Psi'};
         create &TempWork from Y[colname=oname];
         append from Y;
         close &TempWork;
      run;
      quit;

      data _null_;
         set &TempWork end=lastobs;
         retain maxpsi 0;
         if (abs(Psi)>maxpsi) then maxpsi=abs(Psi);
         if (lastobs) then do;
            maxpsi=ceil(maxpsi);
            if (maxpsi<=1) then do;
               psistep=0.25;
            end;
            else if (maxpsi<=2) then do;
               psistep=0.5;
            end;
            else if (maxpsi<=5) then do;
               psistep=1;
            end;
            else if (maxpsi<=10) then do;
               if (mod(maxpsi,2)=1) then maxpsi=maxpsi+1;
               psistep=2;
            end;
            else if (maxpsi<=50) then do;
               if (mod(maxpsi,5)^=0) then maxpsi=5*ceil(maxpsi/5);
               psistep=5;
            end;
            else do;
               if (mod(maxpsi,5)^=0) then maxpsi=5*ceil(maxpsi/5);
               psistep=maxpsi/5;
            end;
            call symput("MAXPSI",put(maxpsi,6.0));
            call symput("PSISTEP",put(psistep,6.2));
         end;
      run;
      /*---------------------------------------*/
      /*----   Truncate the weight series  ----*/
      /*---------------------------------------*/
      proc sort data=&TempWork;
         by descending Lag;
      run;
      data &TempWork;
         set &TempWork;
         retain flag 0;
         Lag=Lag-1;
         if (flag=0) and (abs(Psi)>abs(&CUTOFF*&MAXPSI)) then flag=1;
         if (flag=1) then output;
      run;
      proc sort data=&TempWork;
         by Lag;
      run;
      %if (%ODSOK()) %then %do;

         proc sgplot data=&TempWork;
            vbar Lag / Response=Psi Stat=sum;
            refline 0 / axis=y;
         run;

      %end;
      %else %do;
         axis1 label=("Transfer Function") 
               order=(-&MAXPSI to &MAXPSI by &PSISTEP);

         proc gchart data=&TempWork;
            /*----  Psi Weight Chart  ----*/
            vbar Lag / discrete 
                        sumvar=Psi 
                        ref=0 
                        raxis=axis1;
         run;
         quit;
      %end;
      %if (&OutDS ne ) %then %do;
         data &OutDS;
            attrib Lag length=4 label="Lag"
                   TransferFunction length=8 label="Transfer Function";
            set &TempWork(rename=(Lag=Lags));
            Lag=Lags;
            TransferFunction=Psi;
            keep Lag TransferFunction;
         run;
      %end;
      %DeleteDS(&TempWork);
   %end;
   %else %do;
      %put ERROR: Macro PlotPsi requires SAS/IML.;
   %end;
%mend PlotPsi;

/*----------------------------------------------------*\
 |   Macro: PlotParms                                 |
 +----------------------------------------------------+
 |   Plot autoregressive coefficients from PROC       |
 |   FORECAST estimates data set.                     |
 +----------------------------------------------------+
 |  EXAMPLE                                           |
 +----------------------------------------------------+
ods html;
%PlotParms(DSName=work.temp,TargetVar=Y);
ods html close;
\*----------------------------------------------------*/
%macro PlotParms(DSName=,TargetVar=);
   %if (%ODSOK()) %then %do;
   %let TempData=%RandWorkData();
   %let NumVars=%GetNumVars(&DSName);
   %if (&NumVars eq 3) %then %do;
      data &TempData;
         attrib Lag length=4 label="Lag"
                Estimate length=8 label="Autoregressive Coefficient";
         set &DSName end=lastobs;
         retain PlotMin 100 PlotMax -100;
         if (substr(_TYPE_,1,3)="ARS") then delete;
         if (substr(_TYPE_,1,2)='AR') then do;
            Lag=substr(_TYPE_,3)+0;
            Estimate=&TargetVar;
            if (Estimate=.) then Estimate=0;
            output;
            if (Estimate<PlotMin) then PlotMin=Estimate;
            if (Estimate>PlotMax) then PlotMax=Estimate;
         end;
         if (lastobs) then do;
            if (PlotMin>=0) then do;
               PlotMin=0;
               PlotMax=1.073*PlotMax;
               PlotMax=round(PlotMax,0.1);
            end;
            else if (PlotMax<=0) then do;
               PlotMax=0;
               PlotMin=1.073*PlotMin;
               PlotMin=-round(-PlotMin,0.1);
            end;
            else do;
               PlotMax=PlotMax+0.073*(PlotMax-PlotMin);
               PlotMin=PlotMin-0.073*(PlotMax-PlotMin);
               PlotMax=round(max(abs(PlotMin),PlotMax),0.1);
               PlotMin=-PlotMax;
            end;
            call symput("PlotMin",PlotMin);
            call symput("PlotMax",PlotMax);
         end;
         keep Lag Estimate;
      run;
      proc sort data=&TempData;
         by descending Lag;
      run;
      data &TempData;
         set &TempData;
         retain PutIt 0;
         if (PutIt=0) and (abs(Estimate)>0) then PutIt=1;
         if (PutIt=1) then output;
      run;
      proc sort data=&TempData;
         by Lag;
      run;

      proc sgplot data=&TempData;
         vbar Lag / Response=Estimate;
         refline 0 / axis=y;
         yaxis min=&PlotMin max=&PlotMax;
      run;

      %DeleteDS(&TempData);
   %end;
   %else %do;
      %put ERROR: In macro PlotParms, &DSName is not an estimates data set.;
   %end;
   %end;
   %else %do;
      %put ERROR: ODS GRAPHICS are required by macro PlotParms.;
   %end;
%mend PlotParms;


/*----------------------------------------------------*\
 |   Macro: AllTSPlots                                |
 |   Obtain all time series plots using PROC          |
 |   TIMESERIES                                       |
 +----------------------------------------------------+
 |   NOTE: Currently only for EG environment          |
 |        or for an environment where                 |
 |                                                    |    
 |       ODS HTML;                                    |    
 |                                                    |   
 |       has been specified.                          |   
 +----------------------------------------------------+
 |  EXAMPLE                                           |
 +----------------------------------------------------+
 |  ods html;                                         |
 |  %AllTSPlots(DSName=work.temp,TargetVar=Y,         |
 |              DateVar=Date);                        |
 |  ods html close;                                   |
\*----------------------------------------------------*/
%macro AllTSPlots(DSName=,TargetVar=,DateVar=Date,PeriodPlot=N);
   %if (%ODSOK()) %then %do;
   %global SeasonalPeriod TimeInt;
   %GetInterval(&DSName,&DateVar);

   %let TempData=%RandWorkData();
   proc summary data=&DSName min;
      var &TargetVar;
      output out=&TempData
             min=min;
   run;
   data _null_;
      set &TempData;
      if (min>0) and ("&SeasonalPeriod" ne "1") then do;
         call symput("DecompOpt","1");
      end;
      else do;
         call symput("DecompOpt","0");
      end;
   run;
   %if (&DecompOpt eq 1) and ("%upcase(&PeriodPlot)" eq "Y") %then %do;
      %let TempSeason=&TempData.s;
      %let TempDecomp=&TempData.d;
   %end;

   proc timeseries data=&DSName
                   out=&TempData
   %if (&DecompOpt eq 1) and ("%upcase(&PeriodPlot)" eq "Y") %then %do;
                   outseason=&TempSeason
                   outdecomp=&TempDecomp 
   %end;
                   plot=(series corr acf pacf iacf wn
   %if (&DecompOpt eq 1) %then %do;
                         decomp tc sc
   %end;
                        )
                   seasonality=&SeasonalPeriod;
      id &DateVar interval=&TimeInt;
      var &TargetVar;
   %if (&DecompOpt) %then %do;
      decomp tcc sc / mode=mult;
   %end;
   run;
  
   %if (&DecompOpt eq 1) and ("%upcase(&PeriodPlot)" eq "Y") %then %do;
      proc datasets library=work nolist nodetails;
         modify %scan(&TempSeason,2,%str(.));
         label MEAN="Mean &TargetVar"
               _SEASON_="%upcase(%substr(&TimeInt,1,1))%lowcase(%substr(&TimeInt,2))";
      run;
      quit;
      proc sgplot data=&TempSeason;
         vbar _SEASON_ / response=MEAN;
      run;
      %let NumDecomp=%GetNumObs(&TempDecomp);
      data &TempDecomp;
         set &TempDecomp(firstobs=%eval(&NumDecomp-2*&SeasonalPeriod+1));
         keep &DateVar _SEASON_ SC;
      run;

      proc sql noprint;
         select max(SC),min(SC) into :MaxSC,:MinSC
         from &TempDecomp;
      quit;

      proc sgplot data=&TempDecomp;
         series x=&DateVar y=SC /
            lineattrs=GraphPrediction(pattern=1 color=darkblue);
         refline 1 / axis=y
               lineattrs=GraphPrediction(pattern=2 color=blue);
         yaxis min=%sysfunc(min(%sysfunc(round(0.95*&MinSC,0.1)),0.8)) 
               max=%sysfunc(max(%sysfunc(round(1.05*&MaxSC,0.1)),1.2));
      run;

      data &TempDecomp;
         set &TempDecomp(firstobs=%eval(&SeasonalPeriod+1));
         label _SEASON_="Month";
      run;
/*
      proc sgplot data=&TempDecomp;
         needle x=&DateVar y=SC /
            lineattrs=GraphPrediction(pattern=1 thickness=15 color=darkblue);
         refline 1 / axis=y
            lineattrs=GraphPrediction(pattern=2 color=blue);
      run;
*/
      proc sgplot data=&TempDecomp;
         vbar _SEASON_ / response=SC
            barwidth=0.5 fillattrs=GraphPrediction(color=darkblue);
         refline 1 / axis=y
            lineattrs=GraphPrediction(pattern=2 color=blue);
      run;

      %DeleteDS(&TempSeason);
      %DeleteDS(&TempDecomp);
   %end;
   %DeleteDS(&TempData);
   %end;
   %else %do;
      %put ERROR: ODS GRAPHICS are required by macro AllTSPlots.;
   %end;
%mend AllTSPlots;


/*----------------------------------------------------*\
 |    NAME: PlotMAPE                                  |
 |   TITLE: Plot MAPE overlayed on APE for Holdout    |
 |          Sample                                    |
 |                                                    |
 |   ODS options and graphics options via GOPTIONS    |
 |   should be specified before calling this macro.   |
 |                                                    |
\*----------------------------------------------------*/
%macro PlotMAPE(DSName=,ActualVar=ACTUAL,ForeVar=FORECAST,DateVar=DATE);
   %let TempPlot=%RandWorkData();
   data &TempPlot;
      set &DSName end=lastobs;
      retain MAPE 0 APE 0;
      if (Lead=0) then delete;
      else do;
         APE=100*abs(&ActualVar-&ForeVar)/&ActualVar;
         if (&ActualVar<&ForeVar) then Sign=-1;
         else if (&ActualVar>&ForeVar) then Sign=1;
         else sign=0;
         MAPE=MAPE+APE;
         output;
      end;
      if (lastobs) then do;
         MAPE=MAPE/Lead;
         call symput('MAPE',put(MAPE,20.10));
         call symput('LEAD',put(Lead,3.0));
      end;
      keep APE Sign Lead;
   run;

   %put MAPE=&MAPE  Lead=&Lead;

   %if (%ODSOK()) %then %do;

      proc sgplot data=&TempPlot;
         vbar Lead / Response=APE Stat=sum;
         refline &MAPE / axis=y;
      run;

   %end;
   %else %do;
      pattern1 color=DARKBLUE
               value=solid;
      legend1 position=(bottom center)
              label=("Red Line is MAPE=&MAPE" color=RED);
      proc gchart data=&TempPlot;
         vbar Lead/SumVar=APE
                   type=MEAN
                   href=&MAPE
                   lref=1
                   cref=RED
                   discrete
                   legend=legend1;
      run;
      quit;
   %end;
   %DeleteDS(&TempPlot);
%mend PlotMAPE;

/*----------------------------------------------*\
 |  Macro: PlotSeriesPlus                       |
 +----------------------------------------------+
 |  Plot original series and min mean max.      |
\*----------------------------------------------*/
%macro PlotSeriesPlus(DSName=_LAST_,TargetVar=,
                      DateVar=Date);

   %let TempPlot=%RandWorkData();

   proc summary data=&DSName min mean idmin;
      var &TargetVar;
      output out=&TempPlot 
             maxid(&TargetVar(&DateVar))=MaxDate
             max=Max
             minid(&TargetVar(&DateVar))=MinDate
             min=Min 
             mean=Mean;
   run;
   data _null_;
      set &TempPlot;
      call symput("TargetMin",Min);
      call symput("MinDate",put(MinDate,best17.0));
      call symput("TargetMax",Max);
      call symput("MaxDate",put(MaxDate,best17.0));
      call symput("TargetMean",Mean);
   run;
   /*
   %put TargetMin=&TargetMin TargetMax=&TargetMax;
   %put TargetMean=&TargetMean ;
   %put MinDate=&MinDate MaxDate=&MaxDate;
   */
   data _null_;
      if (&TargetMin>=0) then do;
         call symput("PlotMin","0");
         ND=log10(&TargetMax);
         PlotMax=10**ceil(ND);
         PlotInt=PlotMax/10;
         PlotMax=round(10**(1.02*ND),min(10,PlotInt));
         if (PlotMax < &TargetMax) then 
            PlotMax=round(&TargetMax + 0.05*(&TargetMax-&TargetMin));
         call symput("PlotMax",PlotMax);
         call symput("PlotInt",PlotInt);
      end;
   run;
   /* 
   %put TargetMax=&TargetMax PlotMax=&PlotMax;
   */ 
   data &TempPlot;
      set &DSName;
      TargetMin=&TargetMin;
      TargetMax=&TargetMax;
      TargetMean=&TargetMean;
   run;

   %if (%ODSOK()) %then %do;

      proc sgplot data=&TempPlot;
         series  x=&DateVar y=&TargetVar /
                 legendlabel="&TargetVar" name="series0";
         series  x=&DateVar y=TargetMax / 
                 lineattrs=GraphPrediction(pattern=2 color=red)
                 legendlabel="Max" name="series1";
         series  x=&DateVar y=TargetMin / 
                 lineattrs=GraphPrediction(pattern=2 color=blue)
                 legendlabel="Min" name="series2";
         series  x=&DateVar y=TargetMean / 
                 lineattrs=GraphPrediction(pattern=4 color=green)
                 legendlabel="Mean" name="series3";
         refline &MinDate / axis=x; 
         refline &MaxDate / axis=x;
         yaxis min=0 max=&PlotMax;
         keylegend "series0" "series1" "series2" "series3" / 
                   location=outside position=bottom;
      run;

   %end;
   %else %do;
   symbol1 color=black
           interpol=join
           value=circle
           line=1
           width=2
           height=.5;
   symbol2 color=red
           interpol=join
           value=none
           line=2
           width=2;
   symbol3 color=blue
           interpol=join
           value=none
           line=2
           width=2;
   symbol4 color=green
           interpol=join
           value=none
           line=2
           width=2;

   axis1 label=(h=1.5 justify=c angle=90 
                font=&COURSEFONT "&TargetVar")
         width=2
         order=(&PlotMin to &PlotMax by &PlotInt)
         value=(h=1.2 f=&COURSEFONT);
   axis2 label=(h=1.5 justify=c font=&COURSEFONT "&DateVar")
         width=2
         value=(h=1.2 f=&COURSEFONT);

   proc gplot data=&TempPlot;
      plot (&TargetVar TargetMax TargetMin TargetMean)
           *&DateVar/overlay
                     vaxis=axis1
                     haxis=axis2
                     chref=(blue red)
                     href=&MinDate &MaxDate;
   run;
   quit;
   %end;
   %DeleteDS(&TempPlot);
%mend PlotSeriesPlus;

/*---------------------------------------------*\
 |  Macro: PlotEstimates                       |
 +---------------------------------------------+
 |  Purpose: For an input data set from        |
 |           PROC ARIMA produced using table   |
 |           ParameterEstimates from ODS       |
 |           output, given a variable name,    |
 |           produce a needle plot of the      |
 |           estimates with shaded confidence  |
 |           bands, and then produce a         |
 |           second plot of the p-values       |
 |           associated with the estimates     |
 |           plotted on a log scale.           |
 +---------------------------------------------+
 |  Usage:                                     |
 |  %PlotEstimates(DSName=SAS-data-set-name,   |
 |                 InputVar=variable-name);    |
 +---------------------------------------------+
 |  Example:                                   |
 |  ods html;                                  |
 |  %PlotEstimates(DSName=work.ParmEst,        |
 |                 InputVar=Price);            |
 |  ods html close;                            |
 +---------------------------------------------+
 |                                             |
 |                                             |
\*---------------------------------------------*/
%macro PlotEstimates(DSName=,InputVar=);
   %if (%ODSOK()) %then %do;
   %let TempPlot=%RandWorkData();
   data &TempPlot;
      set &DSName;
      PValue=round(1-log10(Probt),0.0001);
      Lower=-2*StdErr;
      Upper=+2*StdErr;
      if (Variable="&InputVar") then output;
      keep Lag PValue Estimate Lower Upper;
   run;

   proc sgplot data=&TempPlot;
      band x=Lag lower=Lower upper=Upper /
           legendlabel="95% CI" name="band1"; 
      needle  x=Lag y=Estimate / 
              lineattrs=GraphPrediction(pattern=1 thickness=15 color=darkblue)
              legendlabel="Estimate" name="series";
      refline 0 / axis=y;
      keylegend "series" "band1" / location=outside position=bottom;
   run;
   proc sgplot data=&TempPlot;
      vbar Lag / Response=PValue;
      refline 2 / axis=y
         lineattrs=GraphPrediction(pattern=1 color=green)
         legendlabel="p=0.1" name="series0";;
      refline 2.301 / axis=y
         lineattrs=GraphPrediction(pattern=4 color=green)
         legendlabel="p=0.05" name="series1";
      refline 3 / axis=y
         lineattrs=GraphPrediction(pattern=2 color=green)
         legendlabel="p=0.01" name="series2";
      yaxis min=1 max=3.2 display=(noline noticks novalues)
         label="1-(Prob>t)";
      keylegend "series0" "series1" "series2" /
         title="Signicance of Estimates" 
         location=outside position=bottom; 
   run;

   %DeleteDS(&TempPlot);
   %end;
   %else %do;
      %put ERROR: ODS GRAPHICS are required by macro PlotEstimates.;
   %end;
%mend PlotEstimates;

%macro LoadMessage();
   %put ForecastPlotMacros.sas Loaded for SAS Version &SYSVER.;
   %if (%ODSOK()) %then %do;
      %put ForecastPlotMacros.sas Loaded with ODS Statistical Graphics.;
   %end;
   %else %do;
      %put ForecastPlotMacros.sas Loaded WITHOUT ODS Statistical Graphics.;
   %end;
   %if %sysprod(graph)=0 %then %do;
      %put ERROR: SAS/GRAPH is not licensed on this platform.;
   %end;
%mend LoadMessage;

%LoadMessage();

/*--------------------------*/
/*----  End of program  ----*/
/*--------------------------*/



