

libname WN "C:\Users\winado\Desktop\AX 2018\data";

/*Import shutle data*/
DATA WORK.SHUTTLE (keep=sensor t);
    LENGTH
        sensor                 8 ;
    INFILE 'C:\Users\winado\Desktop\AX 2018\data\shuttle.txt'
        LRECL=18
        ENCODING="WLATIN1"
        TERMSTR=CRLF
        DLM='7F'x
        MISSOVER
        DSD ;
    INPUT
        F1               : $CHAR1.
        sensor               : COMMA15.
        F3               : $CHAR1. ;
	t+1;
RUN;

/*Viya Documentation*/
https://go.documentation.sas.com/?docsetId=castsp&docsetTarget=castsp_mtf_sect081.htm&docsetVersion=8.2&locale=en

/*Keogh Discords*/
http://www.cs.ucr.edu/%7Eeamonn/discords/

/*ECG Physiobank annotations*/
https://www.physionet.org/physiobank/annotations.shtml

/*RACE Image*/
http://race.exnet.sas.com/MyActiveRes