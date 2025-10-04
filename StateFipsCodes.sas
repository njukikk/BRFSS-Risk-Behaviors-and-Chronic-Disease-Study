PROC IMPORT OUT= WORK.STATEFIPSCODES 
            DATAFILE= "M:\STA 502\1. Project\Data\StateFIPSicsprAB.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
