/**********************************************************************
* Project           : MS62
*            		: Step 3A-Single exposure models for BMI
* Author            : CK
* Date created      : 06/23/2020
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
 set out.analysisObesity;
 where exclude = 0;
run;
proc means data = foranalysis n mean;
var svyage;
output out = meananalysis;
run;
proc print data = meananalysis;run;


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

    SVYAGE_10 = (SVYAGE - 42.343181818) / 10;

RUN;
proc standard data= renameZscore mean=0 std=1
              out=zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc print data = zscores (obs = 20); run;



*linear model for continuous outcome;

ods graphics on;
%Macro Model(var);

proc mixed data=zscores noclprint covtest empirical PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale svyedu (ref='1:Less than primary') iso2 (ref="BR");
model  obesity = &var SVYAGE_10 SVYAGE_10*SVYAGE_10 svymale svyedu iso2 / solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnB&var 
           FitStatistics=FS_MmodelnB&var 
           CovParms=CP_MmodelnB&var;
run;


proc mixed data=zscores noclprint covtest empirical PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale svyedu (ref='1:Less than primary') iso2 (ref="BR");
model  obesity = &var SVYAGE_10 SVYAGE_10*SVYAGE_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR iso2 / solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnD&var 
           FitStatistics=FS_MmodelnD&var 
           CovParms=CP_MmodelnD&var;
run;

%MEND;
%Model (BECADINTDENSL2_ZSCR);
options mprint = off;
%Model (BECMEDNDVINL2_ZSCR);
%Model (BECPOPDENSL2_ZSCR); 
%Model (CNSSE3_L2_ZSCR);
%Model (BECPCTURBANL1AD_ZSCR);
%Model (BECAWMNNNGHL1AD_ZSCR); 


proc mixed data=zscores noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale svyedu(ref='1:Less than primary') iso2(ref='BR');
model  obesity= BECPTCHDENSL1AD_ZSCR svyage_10 svyage_10*svyage_10 svymale svyedu iso2 / solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnBBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnBBECPTCHDENSL1AD_ZSCR
           CovParms=CP_MmodelnBBECPTCHDENSL1AD_ZSCR;
run;

proc mixed data=zscores noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale svyedu(ref='1:Less than primary') iso2(ref='BR') ;
model  obesity= BECPTCHDENSL1AD_ZSCR svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR iso2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnDBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnDBECPTCHDENSL1AD_ZSCR
           CovParms=CP_MmodelnDBECPTCHDENSL1AD_ZSCR;
run;

proc mixed data=zscores noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale svyedu(ref='1:Less than primary') iso2(ref='BR');
model  obesity= BECPTCHDENSL1AD_ZSCR svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR /*BECPCTURBANL1AD_ZSCR*/ iso2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnXBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnXBECPTCHDENSL1AD_ZSCR
           CovParms=CP_MmodelnXBECPTCHDENSL1AD_ZSCR;
run;
proc mixed data=zscores noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale svyedu (ref='1:Less than primary') iso2(ref='BR');
model  obesity= BECPTCHDENSL1AD_ZSCR svyage_10 svymale svyage_10*svyage_10 svyedu BECPCTURBANL1AD_ZSCR iso2 / solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnYBECPTCHDENSL1AD_ZSCR
           FitStatistics=FS_MmodelnYBECPTCHDENSL1AD_ZSCR
           CovParms=CP_MmodelnYBECPTCHDENSL1AD_ZSCR;
run;
ods graphics off;


%macro combineModel (var);

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

	 keep tValue Probt estimate Lower Upper stderr type label; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, iso2);
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

proc transpose data = allParEst&var
                out = trPE&var.low
				 prefix = lower;
by label;
id type;
var lower;
run;

proc transpose data = allParEst&var
                out = trPE&var.up
				 prefix = upper;
by label;
id type;
var upper;
run;

data transposePE&var;
  merge trPE&var.Est
        trPE&var.low
		trPE&var.up
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
else if index (label,"BECPCTURBAN") then order = 12;
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

%mend;
options mprint;
%combineModel (BECADINTDENSL2_ZSCR);
options mprint = off;
%CombineModel (BECMEDNDVINL2_ZSCR);
%CombineModel (BECPOPDENSL2_ZSCR); 
%CombineModel (CNSSE3_L2_ZSCR);
%CombineModel (BECPCTURBANL1AD_ZSCR);
%CombineModel (BECAWMNNNGHL1AD_ZSCR); 



**Combine 3 fragmentation models;


%macro combineModel2 (var);

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

	 keep tValue Probt estimate Lower Upper stderr type label; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, iso2);
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

proc transpose data = allParEst&var
                out = trPE&var.low
				 prefix = lower;
by label;
id type;
var lower;
run;

proc transpose data = allParEst&var
                out = trPE&var.up
				 prefix = upper;
by label;
id type;
var upper;
run;

data transposePE&var;
  merge trPE&var.Est
        trPE&var.low
		trPE&var.up
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
else if index (label,"BECPCTURBAN") then order = 12;
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

%mend;
options mprint; 
%CombineModel2 (BECPTCHDENSL1AD_ZSCR);

title;


ODS listing close;
ODS tagsets.ExcelXP file = ".....\Output\BMI Models (1) and (2) 01-19.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');



%Macro table(var, label);
ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="&var");


proc report nowd data=transposePE&var;
title "&label Paramater Estimates";
column label ("Model 1 BMI = Age+sex+EDU+country+&label"("Model 1" Estimatemodel2 lowermodel2 uppermodel2 StdErrmodel2 Tvaluemodel2 Probtmodel2))
             ("Model 2 BMI = Age+sex+EDU+PCT Urban+AnaOScore+country+&label"("Model 2" Estimatemodel4 lowermodel4 uppermodel4 StdErrmodel4 Tvaluemodel4 Probtmodel4));
define label / display '';
define Estimatemodel2 / display  'Estimate';
define lowermodel2 / display  'Lower';
define uppermodel2 / display  'Upper';
define StdErrmodel2 / display  'StdError'; 
define Tvaluemodel2 / display 'tValue';
define Probtmodel2 / display 'Probt' ;

define Estimatemodel4 / display  'Estimate';
define lowermodel4 / display  'Lower';
define uppermodel4 / display  'Upper';
define StdErrmodel4 / display  'StdError'; 
define Tvaluemodel4 / display 'tValue';
define Probtmodel4 / display 'Probt' ;
run;

proc report nowd data=transposeFS&var;
title "&label Fit Statistics";
column DESCR   ('Model 1' model2 )   
               ('Model 2' model4)  ;
define DESCR / display '';
define model2 / display 'Value';
define model4 / display 'Value';

run;




proc print data = CP_MmodelnB&var noobs; title "Covariance model 1";
run;
proc print data = CP_MmodelnD&var noobs; title "Covariance model 2";
run;


%MEND;


%Macro table2(var, label);
ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="&var");


proc report nowd data=transposePE&var;
title "&label Paramater Estimates";
column label ("Model 1 BMI = Age+sex+EDU+country+&label"("Model 1" Estimatemodel1 lowermodel1 uppermodel1 StdErrmodel1 Tvaluemodel1 Probtmodel1))
             ("Model 2 BMI = Age+sex+EDU+PCT Urban+AnaOScore+country+&label"("Model 2" Estimatemodel2 lowermodel2 uppermodel2 StdErrmodel2 Tvaluemodel2 Probtmodel2))
             ("Model 3 BMI = Age+sex+EDU+AnaOScore+country+&label"("Model 3" Estimatemodel3 lowermodel3 uppermodel3 StdErrmodel3 Tvaluemodel3 Probtmodel3))
             ("Model 4 BMI = Age+sex+EDU+PCT Urban+country+&label"("Model 4" Estimatemodel4 lowermodel4 uppermodel4 StdErrmodel4 Tvaluemodel4 Probtmodel4));


define label / display '';
define Estimatemodel1 / display  'Estimate';
define lowermodel1 / display  'Lower';
define uppermodel1 / display  'Upper';
define StdErrmodel1 / display  'StdError'; 
define Tvaluemodel1 / display 'tValue';
define Probtmodel1 / display 'Probt' ;

define Estimatemodel2 / display  'Estimate';
define lowermodel2 / display  'Lower';
define uppermodel2 / display  'Upper';
define StdErrmodel2 / display  'StdError'; 
define Tvaluemodel2 / display 'tValue';
define Probtmodel2 / display 'Probt' ;

define Estimatemodel3 / display  'Estimate';
define lowermodel3 / display  'Lower';
define uppermodel3 / display  'Upper';
define StdErrmodel3 / display  'StdError'; 
define Tvaluemodel3 / display 'tValue';
define Probtmodel3 / display 'Probt' ;

define Estimatemodel4 / display  'Estimate';
define lowermodel4 / display  'Lower';
define uppermodel4 / display  'Upper';
define StdErrmodel4 / display  'StdError'; 
define Tvaluemodel4 / display 'tValue';
define Probtmodel4 / display 'Probt' ;


run;

proc report nowd data=transposeFS&var;
title "&label Fit Statistics";
column DESCR   ('Model 1' model1 )   
               ('Model 2' model2 ) 
               ('Model 3' model3 )
			   ('Model 4' model4 );

define DESCR / display '';
define model1 / display 'Value';
define model2 / display 'Value';
define model3 / display 'Value';
define model4 / display 'Value';

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


%table (BECADINTDENSL2_ZSCR, Intersection Density);
options mprint =off;
%table (BECMEDNDVINL2_ZSCR, Urban Greenness);
%table (BECPOPDENSL2_ZSCR, Population Density); 
%table (CNSSE3_L2_ZSCR, SEC Ana Ortigoza Factor);
%table (BECPCTURBANL1AD_ZSCR, Pct Urban);
%table (BECAWMNNNGHL1AD_ZSCR, Urban Isolation); 

options mprint;
%table2 (BECPTCHDENSL1AD_ZSCR, Patch Density);

ods tagsets.excelxp close;
ods listing;
