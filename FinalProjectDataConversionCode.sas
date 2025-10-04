/*STA 502: Statistical Programming

Fall Semester 2019 

Final SAS Project

Author: Kelvin Njuki

Due Date: 12/13/2019*/

/*BRFSS 2018 Data Conversion Code: The code converts data from XPT Transport format 
(LLCP2018.XPT)to SAS data set*/

***********************************************************************************
* FILE NAME:     TRANSPRT.SAS                                                     *
* DESCRIPTION:   THIS PROGRAM CONVERTS A SAS TRANSPORT FILE LOCATED AT <TRANSPRT> *
*                LIBNAME, INTO A SAS DATABASE STORED AT <DATAOUT> LIBREF          *
* REFERENCES:                                                                     *
* INPUT       DATAIN           FILEREF OF TRANSPORT DATAFILE OF COMPLETES         *
* OUTPUT      DATAOUT.SASDATA  SAS DATABASE VERSION OF TRANSPORT DATA AS          *
*                              SPECIFIED IN <TRANSPRT> LIBNAME                    *
* UPDATED - 05/22/2013                                                            *
***********************************************************************************;
********************************
* Clear Output and Log Windows *
********************************;
DM OUTPUT 'clear' continue;
DM LOG    'clear' continue;
**********************************
* DEFINE SAS ENVIRONMENT OPTIONS *
**********************************;
OPTIONS PAGENO=1 NOFMTERR;
***************************************
* CLEAR EXISTING TITLES AND FOOTNOTES *
***************************************;
TITLE ;
FOOTNOTE ;
RUN ;

LIBNAME TRANSPRT XPORT 'M:\STA 502\Final SAS Project\Finals\LLCP2018.XPT';

LIBNAME project V7 'M:\STA 502\Final SAS Project\Finals';

PROC COPY IN=TRANSPRT OUT=project;
RUN;
