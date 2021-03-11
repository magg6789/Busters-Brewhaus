* This program is called Busters5_5645.sas;

* First, clean the log and results windows;
ODS HTML CLOSE ;
ODS HTML ;
DM 'LOG; CLEAR; ODSRESULTS; CLEAR' ;

* The next line of code inserts a title on the first line of each page of output;
*TITLE ' Miriam Garcia ' ;

* The next block of code reads the data file from the D drive;
PROC IMPORT DATAFILE = ' E:Busters3_5645.CSV ' 
  OUT = BUSTERS1
  DBMS = CSV
  REPLACE ;
  GETNAMES = YES ;
  RUN ;

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

* Compute summary statistics for sales ;
PROC MEANS MAXDEC=2;
  VAR SALES;
  RUN;

ODS GRAPHICS OFF;
*Previous 5 Potential Models; 
PROC REG;
  P: MODEL Sales = married_pop inc_40kto100k cover_charge baseball Strip_mall Stand_alone Hooters Buffalo;
  Q: MODEL Sales = married_pop Restaurant_score champion cover_charge W_MW SW Hooters Buffalo;
  R: MODEL Sales = married_pop Played_baseball Played_basketball Played_hockey football Cover_charge Hooters Buffalo;
  S: MODEL Sales = married_pop occ_repair football cover_charge W_MW SW Hooters Buffalo;
  T: MODEL Sales = married_pop inc_40kto100k champion cover_charge W_MW SW Hooters Buffalo;
  RUN;

*Forward-selection method;
PROC REG;
   Forward: MODEL SALES = Married_pop Inc_40Kto100K Occ_repair Played_football Played_baseball Played_basketball 
Played_hockey restaurant_score football baseball cover_charge champion Hooters Buffalo
 / SELECTION=FORWARD SLENTRY=0.20  ;
   RUN;

   *Potential better models incorporating multi-characteristic dummy variables;
   PROC REG;
  	U: MODEL Sales = baseball cover_charge champion Hooters Buffalo;
   	V: MODEL Sales = baseball cover_charge champion Hooters Buffalo W_MW SW;
	W: MODEL Sales = baseball cover_charge champion Hooters Buffalo stand_alone strip_mall;
	X: MODEL Sales = baseball cover_charge champion Hooters Buffalo W_MW SW stand_alone strip_mall;
   RUN; 
   *No significant change when adding MT DV so there is no need to incorporate them. 
   P-values indicate they are insignificant and R-Squared doesn't change much;

* Stepwise selection method;
PROC REG;
   STEPWISE: MODEL SALES = Married_pop Inc_40Kto100K Occ_repair Played_football Played_baseball Played_basketball 
Played_hockey restaurant_score football baseball cover_charge champion Hooters Buffalo / SELECTION=STEPWISE SLENTRY=0.20 SLSTAY=0.20;
   RUN;
* Backward selection method;
PROC REG;
   Backward: MODEL SALES = Married_pop Inc_40Kto100K Occ_repair Played_football Played_baseball Played_basketball 
Played_hockey restaurant_score football baseball cover_charge champion Hooters Buffalo / SELECTION=BACKWARD SLSTAY=0.20 ;
   RUN;
 *Backward selection model;
   PROC REG;
  	Y: MODEL Sales = played_football played_basketball Occ_repair played_baseball football restaurant_score played_hockey;
RUN;

* Maximum R-square improvement selection method 
NOTE: Not asked in projects directions but added for completeness;
PROC REG;
   Max_R_square: MODEL SALES = Married_pop Inc_40Kto100K Occ_repair Played_football Played_baseball Played_basketball 
Played_hockey restaurant_score football baseball cover_charge champion Hooters Buffalo / SELECTION=MAXR;
   RUN;

   *13-variable best model with Maximum R-square improvement selection method;
   PROC REG;
   Z: MODEL SALES = Married_pop Inc_40Kto100K Occ_repair played_baseball played_basketball played_hockey restaurant_score 
	football baseball cover_charge champion Hooters Buffalo;
RUN;

* Adjusted R-square selection method;
PROC REG;
   Adj_R_square: MODEL SALES = Married_pop Inc_40Kto100K Occ_repair Played_football Played_baseball Played_basketball 
Played_hockey restaurant_score football baseball cover_charge champion Hooters Buffalo / SELECTION=ADJRSQ BEST=20;
   RUN;
*Model AA will be based on the best Adjusted R-Square model;
   PROC REG;
   AA: MODEL SALES = Married_pop Inc_40Kto100K played_baseball baseball cover_charge champion Hooters Buffalo;
   AB: MODEL SALES = Married_pop Inc_40Kto100K played_baseball baseball cover_charge champion Hooters Buffalo W_MW SW;
   RUN;

* End with a QUIT statement ;
QUIT;
