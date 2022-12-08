/**********************************************************************
* Project           : MS62
*            		: Step 3B-Full models for BMI
* Author            : CK
* Date              : 10/01/2020
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


proc mixed data=zscores noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale  svyedu (ref='1:Less than primary') ISO2(ref='BR');
model  obesity=svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR 
       BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnFullIso
           FitStatistics=FS_MmodelnFullIso
           CovParms=CP_MmodelnFullIso;
run;
*Empty Models;

proc mixed data=zscores noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale ISO2(ref='BR');
model  obesity=svyage_10 svymale ISO2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnEmptyIso
           FitStatistics=FS_MmodelnEmptyIso
           CovParms=CP_MmodelnEmptyIso;
run;


%macro ICCMOR (data, datanew);
proc sql ;
create table icc as
select sum(estimate*(Subject='SALID1')) / sum(estimate) as iccL1AD, 
	   sum(estimate*(Subject='SALID2(SALID1)')) / sum(estimate) as iccL2, 
	   sum(estimate*(CovParm='Residual')) / sum(estimate) as residual,
	   sum(estimate*(CovParm='UN(1,1)')) / sum(estimate) as iccSumL1L2,
	   sum(estimate) as denomenator
from &data ;
quit ;

proc transpose data = ICC out = TRICC
                           prefix = icc;
var ICCL1AD ICCL2 residual denomenator ICCsumL1L2 ICCL1AD;
run;

Data &datanew ;
length subject $200.;
  retain CovParm Subject Estimate StdErr ZValue ProbZ ICC;
  merge TRICC &data;
  icc = icc1;
  drop _name_ icc1;

 if _n_ = 3 then subject = "Residual" ;
 if _n_ = 4 then subject = "Total Variance";
 if _n_ = 4 then estimate = ICC;
 if _n_ = 5 then subject = "Correlation among people in the same L2";
 if _n_ = 6 then subject = "Correlation among people in the same L1 but NOT the same L2";

   Label ICC = "% of variation";
run;
proc print data = &datanew;run;
%mend;

%ICCMOR (CP_Mmodelnfulliso, CP_Mmodelnfulliso_1);
%ICCMOR (CP_Mmodelnemptyiso, CP_Mmodelnemptyiso_1);
ods graphics off;



data PARestFull;
set PAR_Mmodelnfulliso;

	 length label $50.;

	 keep tValue Probt estimate Lower Upper stderr label; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;


run;



*Empty model;
Data PARestEmpty;
 set PAR_MmodelnEmptyIso;

	 length label $50.;

	 keep tValue Probt estimate Lower Upper stderr type label; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;

run;


ODS listing close;
ODS tagsets.ExcelXP file = "......\output\BMI Model Full 1-08.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');
ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Full Model");

proc print data = ParEstFull noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt Lower Upper;
run;
proc print data = FS_MmodelnFullIso noobs; 
title "Fit Statistics";
run;
proc print data = CP_MmodelnFullIso noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
run;
proc print data = CP_MmodelnfullIso_1(firstobs = 5) label noobs; 
title "ICC";
label   ICC = "ICC";
Var subject ICC;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Empty Model");
proc print data = ParEstEmpty noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt Lower Upper;
run;
proc print data = FS_MmodelnEmptyIso noobs; 
title "Fit Statistics";
run;
proc print data = CP_MmodelnEmptyIso noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnEmptyIso_1 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
run;
proc print data = CP_MmodelnEmptyIso_1(firstobs = 5) label noobs; 
title "ICC";
label   ICC = "ICC";
Var subject ICC;
run;

ods tagsets.excelxp close;
ods listing;

