* Project 4 - This program is called Busters4_5645.SAS ;

* First, clean the log and results windows;
ODS HTML CLOSE ;
ODS HTML ;
DM 'LOG; CLEAR; ODSRESULTS; CLEAR' ;

* The next line of code inserts a title on the first line of each page of output;
TITLE ' Miriam Garcia ' ;

* The next block of code reads the data file from the E drive;
PROC IMPORT DATAFILE = ' E:Busters3_5645.CSV ' 
  OUT = BUSTERS1
  DBMS = CSV
  REPLACE ;
  GETNAMES = YES ;
  RUN ;
* Previous projects 1-3 work ;
* The next block of code drops unreasonable & outlier observations for SALES, replaces the missing observation 
  for Pop_45to50, and creates proper dummy variables from the existing qualitative variables.  ;
DATA BUSTERS2;
  SET BUSTERS1;
  IF Store_ID=1 or Store_ID=2 THEN DELETE;
  IF SALES < 1219372 or SALES > 3654479 THEN DELETE;
  IF Pop_45to50 = . THEN Pop_45to50 = 156.68;
  cover_charge = 0;
  IF CC = 2 THEN cover_charge = 1;
  pop_high = 0;
  IF pop_growth = 1 THEN pop_high = 1;
  pop_medium = 0;
  IF pop_growth = 2 THEN pop_medium = 1;
  pop_low = 0;
  IF pop_growth = 3 THEN pop_low = 1;
  pop_negative = 0;
  IF pop_growth = 4 THEN pop_negative = 1;
  West = 0;
  IF Region = "W" THEN West = 1;
  MW = 0;
  IF Region = "MWest" THEN MW = 1;
  SW = 0;
  IF Region = "SWest" THEN SW = 1;
  East = 0;
  IF Region = "e" THEN East = 1;
  drive_thru = 0;
  IF DT = "yes" THEN drive_thru = 1;
  high_tax = 0;
  IF BT = "high" THEN high_tax = 1;
  champion = 0;
  IF champ = "Y" THEN champion = 1;
  Buffalo = 0;
  IF BWW > 0 THEN Buffalo = 1;
  RUN;

* The next block of code cleans up the dummy variables;
DATA BUSTERS3;
  SET BUSTERS2;
  pop_high_medium = pop_high + pop_medium;
  W_MW = West + MW;
  RUN;
* Generate correlation coefficients between sales and the new dummy variables;
PROC CORR;
  VAR SALES Hooters Buffalo Metrics champion high_tax;
  RUN;

ODS GRAPHICS OFF;

PROC REG;
  A: MODEL Sales = pop_45to50 married_pop inc_40Kto100K occ_engineer occ_repair
     played_baseball played_basketball played_bowling played_football played_hockey
	 restaurant_score night_life_score football baseball basketball cover_charge
     W_MW SW stand_alone strip_mall Hooters Buffalo Metrics champion high_tax; /* model with all variables*/ 
  B: MODEL Sales = married_pop inc_40Kto100K occ_engineer played_football football 
     cover_charge W_MW SW stand_alone strip_mall Hooters Buffalo;
  C: MODEL Sales = married_pop inc_40Kto100K occ_repair played_baseball baseball cover_charge
     W_MW SW stand_alone strip_mall Hooters Metrics;
  D: MODEL Sales = married_pop inc_40Kto100K played_basketball basketball cover_charge
     stand_alone strip_mall Hooters champion;
  E: MODEL Sales = married_pop inc_40Kto100K played_football football restaurant_score cover_charge
     stand_alone strip_mall Hooters high_tax;
  F: MODEL Sales = married_pop inc_40Kto100K played_hockey football cover_charge
     stand_alone strip_mall champion;
  G: MODEL Sales = married_pop inc_40Kto100K played_hockey football cover_charge
     W_MW SW champion;
  H: MODEL Sales = married_pop inc_40Kto100K played_football football cover_charge
     W_MW SW champion;
  I: MODEL Sales = married_pop inc_40Kto100K played_hockey played_football football basketball baseball champion;
  J: MODEL Sales = inc_40Kto100K played_basketball played_football played_hockey football basketball baseball champion;
  K: MODEL Sales = inc_40Kto100K played_basketball played_football played_hockey high_tax Hooters Buffalo champion;
  L: MODEL Sales = inc_40Kto100K strip_mall stand_alone W_MW SW high_tax Hooters Buffalo champion;
  M: MODEL Sales = married_pop inc_40Kto100K occ_repair occ_engineer strip_mall stand_alone W_MW SW Hooters Buffalo;
  N: MODEL Sales = married_pop inc_40Kto100K occ_repair occ_engineer basketball football played_football 
           played_basketball Hooters Buffalo;
  O: MODEL Sales = married_pop inc_40Kto100K occ_repair occ_engineer high_tax champion basketball football
           played_basketball Hooters Buffalo;

  P: MODEL Sales = married_pop inc_40kto100k cover_charge baseball Strip_mall Stand_alone Hooters Buffalo;
  Q: MODEL Sales = married_pop Restaurant_score champion cover_charge W_MW SW Hooters Buffalo;
  R: MODEL Sales = married_pop Played_baseball Played_basketball Played_hockey football Cover_charge Hooters Buffalo;
  S: MODEL Sales = married_pop occ_repair football cover_charge W_MW SW Hooters Buffalo;
  T: MODEL Sales = married_pop inc_40kto100k champion cover_charge W_MW SW Hooters Buffalo;

RUN;
/*model P MC check*/
PROC CORR;   
VAR married_pop inc_40kto100k cover_charge baseball Strip_mall Stand_alone Hooters Buffalo;  
RUN;
/*model Q MC check*/
PROC CORR;   
VAR married_pop Restaurant_score champion cover_charge W_MW SW Hooters Buffalo;  
RUN;
/*model R MC check*/
PROC CORR;   
VAR married_pop Played_baseball Played_basketball Played_hockey football Cover_charge Hooters Buffalo;  
RUN;
/*model S MC check*/
PROC CORR;   
VAR married_pop occ_repair football cover_charge W_MW SW Hooters Buffalo;
RUN;
/*model T MC check*/
PROC CORR;   
VAR married_pop inc_40kto100k champion cover_charge W_MW SW Hooters Buffalo;
RUN;

* End with a QUIT statement ;
QUIT;
