 /**********************************************************************
* Project           : MS62
*            		: Step 3A-Single exposure models for Obesity
* Author            : CK
* Date created      : 05/18/2020
**********************************************************************/


libname surveys "....\Health Surveys Shared Code";
libname out "....\SAS Datasets";
options fmtsearch=(surveys.formats);

%let Date = %sysfunc(today(), mmddyyn8.);
%put &Date;
options nofmterr mprint;

proc format;
 value sample
    1 = "Excluded"
    0 = "Included";

 value yesno
    1 = "(1) Yes"
    0 = "(0) No";

 Value popDen
	1 = "Pop density Q1 (low)"
	2 = "Pop density Q2 (mid low)"
	3 = "Pop density Q3 (mid-high)"
	4 = "Pop density Q4 (high)";
run;

Data foranalysis;
 set out.analysisObesityCat;
 where exclude = 0;

run;
proc means data = foranalysis n mean;
var svyage;
output out = meananalysis;
run;
proc print data = meananalysis;
run;


*STANDARDIZE VARS;

 DATA renameZscore;
  SET foranalysis;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 
	SVYAGE_ZSCR = SVYAGE;

    SVYAGE_10 = (SVYAGE - 42.343181818) / 10;

RUN;
proc standard data= renameZscore mean=0 std=1
              out=zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc print data = zscores (obs = 20); run;
proc sort data = zscores; 
by descending obesityCat;
run;
proc freq data = zscores order = data;
table obesityCat svyedu;
run;



ods graphics on;
%Macro Model(var);

ods graphics on;

proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order=data;
class salid1 salid2 svymale svyedu (ref='1:Less than primary') iso2(ref='BR') ;
model  obesityCat= &var svyage_10 svyage_10*svyage_10 svymale svyedu iso2 /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnB&var 
           FitStatistics=FS_MmodelnB&var 
           CovParms=CP_MmodelnB&var
		   OddsRatios=OR_MmodelnB&var;
run;

proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order=data;
class salid1 salid2 svymale svyedu (ref='1:Less than primary') iso2(ref='BR');
model  obesityCat = &var svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR iso2 /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnD&var 
           FitStatistics=FS_MmodelnD&var 
           CovParms=CP_MmodelnD&var
		   OddsRatios=OR_MmodelnD&var;
run;

%MEND;

%Model (BECADINTDENSL2_ZSCR);
%Model (BECMEDNDVINL2_ZSCR);
%Model (BECPOPDENSL2_ZSCR); 
%Model (CNSSE3_L2_ZSCR);
%Model (BECPCTURBANL1AD_ZSCR);
%Model (BECAWMNNNGHL1AD_ZSCR); 

proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order=data;
class salid1 salid2 svymale iso2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= BECPTCHDENSL1AD_ZSCR svyage_10 svyage_10*svyage_10 svymale svyedu iso2 /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnBBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnBBECPTCHDENSL1AD_ZSCR 
           CovParms=CP_MmodelnBBECPTCHDENSL1AD_ZSCR
		   OddsRatios=OR_MmodelnBBECPTCHDENSL1AD_ZSCR;

run;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order=data;
class salid1 salid2 svymale iso2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= BECPTCHDENSL1AD_ZSCR svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR iso2 /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnDBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnDBECPTCHDENSL1AD_ZSCR
           CovParms=CP_MmodelnDBECPTCHDENSL1AD_ZSCR
		   OddsRatios=OR_MmodelnDBECPTCHDENSL1AD_ZSCR;

run;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order=data;
class salid1 salid2 svymale iso2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= BECPTCHDENSL1AD_ZSCR svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR iso2 /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnXBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnXBECPTCHDENSL1AD_ZSCR
           CovParms=CP_MmodelnXBECPTCHDENSL1AD_ZSCR
		   OddsRatios=OR_MmodelnXBECPTCHDENSL1AD_ZSCR;

run;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order=data;
class salid1 salid2 svymale iso2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= BECPTCHDENSL1AD_ZSCR svyage_10 svyage_10*svyage_10 svymale svyedu BECPCTURBANL1AD_ZSCR iso2 /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnYBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnYBECPTCHDENSL1AD_ZSCR
           CovParms=CP_MmodelnYBECPTCHDENSL1AD_ZSCR
		   OddsRatios=OR_MmodelnYBECPTCHDENSL1AD_ZSCR;
run;
ods graphics off;



%macro combineOR (var);

*COMBINE PARAMATER ESTIMATES;


data PAR_EstB&var;
  set PAR_MmodelnB&var;
  type = "model2";
run;

data PAR_EstD&var;
  set PAR_MmodelnD&var;
  type = "model4";
run;

Data allParEst&var;
 set PAR_EstB&var
     PAR_EstD&var;

	 length label $50.;

	 keep tValue Probt type label estimate stderr; 


	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "BRTSUBWAYL1AD" and BRTSUBWAYL1AD = 1 then Label = "BRTSUBWAYL1AD 1:Yes";
	 else if effect = "BRTSUBWAYL1AD" and BRTSUBWAYL1AD = 0 then Label = "BRTSUBWAYL1AD 0:No";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;


run;

proc sort data = allParEst&var;
by label type;
run;
proc print data = allparEst&var;
run;

proc transpose data = allParEst&var
                out = trPE&var.T
				 prefix = Tvalue;
by label;
id type;
var tValue;
run;

proc transpose data = allParEst&var
                out = trPE&var.Pt
				 prefix = Probt;
by label;
id type;
var Probt;
run;

proc transpose data = allParEst&var
                out = trPE&var.Est
				 prefix = Estimate;
by label;
id type;
var Estimate;
run;

proc transpose data = allParEst&var
                out = trPE&var.SE
				 prefix = StdErr;
by label;
id type;
var StdErr;
run;

data transposePE&var;
  merge trPE&var.Est
        trPE&var.SE
        trPE&var.t 
        trPE&var.Pt;
  by label;
  drop _Name_ _Label_;

  length order 8.0;

if label = "Intercept" then order = 01;
else if label = "SVYAGE_10" then order = 02;
else if label = "SVYAGE_10*SVYAGE_10" then order = 03;
else if label = "SVYMALE 0:Female" then order = 04;
else if label = "SVYMALE 1:Male" then order = 05;
else if label = "SVYEDU 1:Less than primary" then order = 06;
else if label = "SVYEDU 2:Primary" then order = 07;
else if label = "SVYEDU 3:Secondary" then order = 08;
else if label = "SVYEDU 4:University" then order = 09;
else if index (label,"&var") then order = 10;
else if index (label,"ISO2") then order = 11;
else if index (label,"BECPCTURBANL1AD") then order = 12;
else if label = "CNSSE3_L2_ZSCR" then order = 13;

run;

proc sort data = transposePE&var;
by order;
run;

proc print data = transposePE&var;
var order label;
run;



*COMBINE FIT STATS;


data FSB&var;
  set FS_MmodelnB&var;
  type = "model2";
run;

data FSD&var;
  set FS_MmodelnD&var;
  type = "model4";
run;

Data allFS&var;
 set FSB&var
     FSD&var;
run;

proc sort data = allFS&var;
by Descr type;
run;

proc transpose data = allFS&var
                out = transposeFS&var;
by DESCR;
id type;
var Value;
run;


*COMBINE ODDS RATIOs;


data OR_MmodelnB&var;
 set OR_MmodelnB&var;
 type = "model2";
run;

data OR_MmodelnD&var;
 set OR_MmodelnD&var;
 type = "model4";
run;

Data allOdds&var;
 set OR_MmodelnB&var
     OR_MmodelnD&var;

	 keep Label type Estimate Lower Upper;

run;

proc sort data = allOdds&var;
by descending label type;
run;

proc transpose data = allodds&var
                out = trOR&var.E
                prefix = odds;
by descending label;
id type;
var Estimate;
run;
proc transpose data = allodds&var
                out = trOR&var.L
				  prefix = lower;
by descending label;
id type;
var lower;
run;
proc transpose data = allodds&var
                out = trOR&var.U
				prefix = upper;
by descending label;
id type;
var upper;
run;


data transposeOR&var;
  merge trOR&var.E trOR&var.L trOR&var.U;
  by descending label;

  drop _Name_ _Label_;

  	length order 8.0;

	if index (label,"SVYAGE") then order = 1;
	else if index (label,"&var")  then order = 2;
	else if index (label,"SVYMALE")  then order = 3;
	else if index (label,"SVYEDU")  then order = 4;
	else if index (label,"ISO")  then order = 5;
	else order = 6;

run;

proc sort data = transposeOR&var;
by order;
run;
%mend;

%combineOR (BECADINTDENSL2_ZSCR);
%CombineOR (BECMEDNDVINL2_ZSCR);
%CombineOR (BECPOPDENSL2_ZSCR); 
%CombineOR (CNSSE3_L2_ZSCR);
%CombineOR (BECPCTURBANL1AD_ZSCR);
%CombineOR (BECAWMNNNGHL1AD_ZSCR);






%macro combineOR2 (var);

*COMBINE PARAMATER ESTIMATES;


data PAR_EstB&var;
  set PAR_MmodelnB&var;
  type = "model1";
run;

data PAR_EstD&var;
  set PAR_MmodelnD&var;
  type = "model2";
run;

data PAR_EstX&var;
  set PAR_MmodelnX&var;
  type = "model3";
run;
data PAR_EstY&var;
  set PAR_MmodelnY&var;
  type = "model4";
run;


Data allParEst&var;
 set PAR_EstB&var
     PAR_EstD&var
     PAR_EstX&var
     PAR_EstY&var;

	 length label $50.;

	 keep tValue Probt type label estimate stderr; 


	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;


run;

proc sort data = allParEst&var;
by label type;
run;
proc print data = allparEst&var;
run;

proc transpose data = allParEst&var
                out = trPE&var.T
				 prefix = Tvalue;
by label;
id type;
var tValue;
run;

proc transpose data = allParEst&var
                out = trPE&var.Pt
				 prefix = Probt;
by label;
id type;
var Probt;
run;

proc transpose data = allParEst&var
                out = trPE&var.Est
				 prefix = Estimate;
by label;
id type;
var Estimate;
run;

proc transpose data = allParEst&var
                out = trPE&var.SE
				 prefix = StdErr;
by label;
id type;
var StdErr;
run;

data transposePE&var;
  merge trPE&var.Est
        trPE&var.SE
        trPE&var.t 
        trPE&var.Pt;
  by label;
  drop _Name_ _Label_;

  length order 8.0;

if label = "Intercept" then order = 01;
else if label = "SVYAGE_10" then order = 02;
else if label = "SVYAGE_10*SVYAGE_10" then order = 03;
else if label = "SVYMALE 0:Female" then order = 04;
else if label = "SVYMALE 1:Male" then order = 05;
else if label = "SVYEDU 1:Less than primary" then order = 06;
else if label = "SVYEDU 2:Primary" then order = 07;
else if label = "SVYEDU 3:Secondary" then order = 08;
else if label = "SVYEDU 4:University" then order = 09;
else if index (label,"&var") then order = 10;
else if index (label,"ISO2") then order = 11;
else if index (label,"BECPCTURBANL1AD") then order = 12;
else if label = "CNSSE3_L2_ZSCR" then order = 13;

run;

proc sort data = transposePE&var;
by order;
run;

proc print data = transposePE&var;
var order label;
run;



*COMBINE FIT STATS;


data FSB&var;
  set FS_MmodelnB&var;
  type = "model1";
run;

data FSD&var;
  set FS_MmodelnD&var;
  type = "model2";
run;

data FSX&var;
  set FS_MmodelnX&var;
  type = "model3";
run;
data FSY&var;
  set FS_MmodelnY&var;
  type = "model4";
run;

Data allFS&var;
 set FSB&var
     FSD&var
     FSX&var
     FSY&var;
run;

proc sort data = allFS&var;
by Descr type;
run;

proc transpose data = allFS&var
                out = transposeFS&var;
by DESCR;
id type;
var Value;
run;


*COMBINE ODDS RATIOs;


data OR_MmodelnB&var;
 set OR_MmodelnB&var;
 type = "model1";
run;

data OR_MmodelnD&var;
 set OR_MmodelnD&var;
 type = "model2";
run;

data OR_MmodelnX&var;
 set OR_MmodelnX&var;
 type = "model3";
run;

data OR_MmodelnY&var;
 set OR_MmodelnY&var;
 type = "model4";
run;

Data allOdds&var;
 set OR_MmodelnB&var
     OR_MmodelnD&var
     OR_MmodelnX&var
     OR_MmodelnY&var;

	 keep Label type Estimate Lower Upper;

run;

proc sort data = allOdds&var;
by descending label type;
run;

proc transpose data = allodds&var
                out = trOR&var.E
                prefix = odds;
by descending label;
id type;
var Estimate;
run;
proc transpose data = allodds&var
                out = trOR&var.L
				  prefix = lower;
by descending label;
id type;
var lower;
run;
proc transpose data = allodds&var
                out = trOR&var.U
				prefix = upper;
by descending label;
id type;
var upper;
run;


data transposeOR&var;
  merge trOR&var.E trOR&var.L trOR&var.U;
  by descending label;

  drop _Name_ _Label_;

  	length order 8.0;

	if index (label,"SVYAGE") then order = 1;
	else if index (label,"&var")  then order = 2;
	else if index (label,"SVYMALE")  then order = 3;
	else if index (label,"SVYEDU")  then order = 4;
	else if index (label,"ISO")  then order = 5;
	else order = 6;

run;

proc sort data = transposeOR&var;
by order;
run;
%mend;

%CombineOR2 (BECPTCHDENSL1AD_ZSCR);

title;

ODS listing close;
ODS tagsets.ExcelXP file = ".....\output\obesityCatModel Model (1) and (2) 01-19.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');

%Macro table(var, label);
ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="&var");


proc report nowd data=transposePE&var;
title "&label Paramater Estimates";
column label ("Model 1 Obesity = Age+sex+EDU+country+&label" ("Model 1" Estimatemodel2 StdErrmodel2 Tvaluemodel2 Probtmodel2))
             ("Model 2 Obesity = Age+sex+EDU+PCT Urban+AnaOScore+country+&label" ("Model 2" Estimatemodel4 StdErrmodel4 Tvaluemodel4 Probtmodel4));

define label / display '';
define Estimatemodel2 / display  'Estimate';
define StdErrmodel2 / display  'StdError'; 
define Tvaluemodel2 / display 'tValue';
define Probtmodel2 / display 'Probt' ;


define Estimatemodel4 / display  'Estimate';
define StdErrmodel4 / display  'StdError'; 
define Tvaluemodel4 / display 'tValue';
define Probtmodel4 / display 'Probt' ;
run;

proc report nowd data=transposeFS&var;
title "&label Fit Statistics";
column DESCR  ('Model 1' model2)   
              ('Model 2' model4);

define DESCR / display '';
define model2 / display 'Value';
define model4 / display 'Value';

run;

proc report nowd data=transposeOR&var;
title "&label Odds Ratios";
column Label ('Model 1' oddsmodel2 lowermodel2  uppermodel2) 
			 ('Model 2' oddsmodel4 lowermodel4 uppermodel4) ;

define label / display '';
define oddsmodel2 / display  'Odds Ratio';
define lowermodel2 / display 'Lower Limit' ;
define uppermodel2 / display 'Upper Limit' ;

define oddsmodel4 / display  'Odds Ratio';
define lowermodel4 / display 'Lower Limit' ;
define uppermodel4 / display 'Upper Limit' ;
run;

proc print data = CP_MmodelnB&var noobs; title "Covariance model 1";
run;
proc print data = CP_MmodelnD&var noobs; title "Covariance model 2";
run;

%MEND;


%table (BECADINTDENSL2_ZSCR, Intersection Density);
%table (BECMEDNDVINL2_ZSCR, Urban Greenness);
%table (BECPOPDENSL2_ZSCR, Population Density); 
%table (CNSSE3_L2_ZSCR, SEC Ana Ortigoza Factor);
%table (BECAWMNNNGHL1AD_ZSCR, Urban Isolation);
%table (BECPCTURBANL1AD_ZSCR, Pct Urban);


%Macro table2(var, label);
ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="&var");

proc report nowd data=transposePE&var;
title "&label Paramater Estimates";
column label ("Model 1 Obesity = Age+sex+EDU+country+&label" ("Model 1" Estimatemodel1 StdErrmodel1 Tvaluemodel1 Probtmodel1))
             ("Model 2 Obesity = Age+sex+EDU+PCT Urban+AnaOScore+country+&label" ("Model 2" Estimatemodel2 StdErrmodel2 Tvaluemodel2 Probtmodel2))
             ("Model 3 Obesity = Age+sex+EDU+AnaOScore+country+&label" ("Model 3" Estimatemodel3 StdErrmodel3 Tvaluemodel3 Probtmodel3))
             ("Model 4 Obesity = Age+sex+EDU+PCT Urban+country+&label" ("Model 4" Estimatemodel4 StdErrmodel4 Tvaluemodel4 Probtmodel4));

define label / display '';
define Estimatemodel1 / display  'Estimate';
define StdErrmodel1 / display  'StdError'; 
define Tvaluemodel1 / display 'tValue';
define Probtmodel1 / display 'Probt' ;

define Estimatemodel2 / display  'Estimate';
define StdErrmodel2 / display  'StdError'; 
define Tvaluemodel2 / display 'tValue';
define Probtmodel2 / display 'Probt' ;

define Estimatemodel3 / display  'Estimate';
define StdErrmodel3 / display  'StdError'; 
define Tvaluemodel3 / display 'tValue';
define Probtmodel3 / display 'Probt' ;

define Estimatemodel4 / display  'Estimate';
define StdErrmodel4 / display  'StdError'; 
define Tvaluemodel4 / display 'tValue';
define Probtmodel4 / display 'Probt' ;
run;

proc report nowd data=transposeFS&var;
title "&label Fit Statistics";
column DESCR  ('Model 1' model1)   
              ('Model 2' model2)
              ('Model 3' model3)
              ('Model 4' model4);

define DESCR / display '';
define model1 / display 'Value';
define model2 / display 'Value';
define model3 / display 'Value';
define model4 / display 'Value';
run;

proc report nowd data=transposeOR&var;
title "&label Odds Ratios";
column Label ('Model 1' oddsmodel1 lowermodel1 uppermodel1) 
			 ('Model 2' oddsmodel2 lowermodel2 uppermodel2) 
             ('Model 3' oddsmodel3 lowermodel3 uppermodel3) 
             ('Model 4' oddsmodel4 lowermodel4 uppermodel4) ;

define label / display '';
define oddsmodel1 / display  'Odds Ratio';
define lowermodel1 / display 'Lower Limit' ;
define uppermodel1 / display 'Upper Limit' ;

define oddsmodel2 / display  'Odds Ratio';
define lowermodel2 / display 'Lower Limit' ;
define uppermodel2 / display 'Upper Limit' ;

define oddsmodel3 / display  'Odds Ratio';
define lowermodel3 / display 'Lower Limit' ;
define uppermodel3 / display 'Upper Limit' ;

define oddsmodel4 / display  'Odds Ratio';
define lowermodel4 / display 'Lower Limit' ;
define uppermodel4 / display 'Upper Limit' ;
run;

proc print data = CP_MmodelnB&var noobs; title "Covariance model 1";
run;
proc print data = CP_MmodelnD&var noobs; title "Covariance model 2";
run;
proc print data = CP_MmodelnX&var noobs; title "Covariance model 3";
run;
proc print data = CP_MmodelnY&var noobs; title "Covariance model 4";
run;


%MEND;


%table2 (BECPTCHDENSL1AD_ZSCR, Patch Density); 

ods tagsets.excelxp close;
ods listing;


