
/**********************************************************************
* Project           : MS62
*            		: Step 3C-Sensitivity models for BMI
* Author            : CK
* Date              : 07/08/2020
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
Data Senanalysis1;  
 set out.analysisObesity;
 where exclude = 0 and iso2 ne "AR"; 
run;
proc means data = Senanalysis1;
var svyage;
run;
Data Senanalysis2;  
 set out.analysisObesity;
 where exclude = 0 and 12 < Obesity < 70 ; 
run;
proc means data = Senanalysis2;
var svyage;
run;
Data Senanalysis3;  
 set out.analysisObesity;
 where exclude = 0 and iso2 in ('AR', 'BR', 'CL', 'MX', 'PE'); 
run;
proc means data = Senanalysis3;
var svyage;
run;
Data Senanalysis4;  
 set out.analysisObesity;
 where exclude = 0; 

 threesd = 7772.75+ (4414.24*3);

 if BECPOPDENSL2 le threesd then flagthree = 0;
 if BECPOPDENSL2 gt threesd then flagthree = 1;

 if flagthree = 0 then output;
run;
proc means data = Senanalysis4;
var svyage;
run;
Data Senanalysis5;  
 set out.analysisObesity;
 where exclude = 0;

 if iso2 in ('PA','SV','GT','NI') then country = 'CA';
 else country = ISO2;
run;
proc means data = Senanalysis5;
var svyage;
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

   svyage_10 = (svyage - 42.343181818) / 10;

RUN;
proc standard data= renameZscore mean=0 std=1
              out=zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR 	; 
run;
proc print data = zscores (obs = 20); run;

******
SEN1;
*STANDARDIZE VARS;

 DATA senrenameZscore;
  SET senanalysis1;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

    SVYAGE_10 = (svyage - 41.7260452) / 10;

RUN;
proc standard data= senrenameZscore mean=0 std=1
              out=senzscores1;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;

*
SEN2;
*STANDARDIZE VARS;

 DATA senrenameZscore;
  SET senanalysis2;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

    SVYAGE_10 = (svyage - 42.3416258) / 10;

RUN;
proc standard data= senrenameZscore mean=0 std=1
              out=senzscores2;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;

*
SEN3;
*STANDARDIZE VARS;

 DATA senrenameZscore;
  SET senanalysis3;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

    SVYAGE_10 = (svyage - 42.6371310) / 10;

RUN;
proc standard data= senrenameZscore mean=0 std=1
              out=senzscores3;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
*
SEN4;
*STANDARDIZE VARS;

 DATA senrenameZscore;
  SET senanalysis4;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

    SVYAGE_10 = (svyage - 42.3660147) / 10;

RUN;
proc standard data= senrenameZscore mean=0 std=1
              out=senzscores4;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;

**SEN5;
 DATA senrenameZscore;
  SET senanalysis5;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

   svyage_10 = (svyage - 42.343181818) / 10;


RUN;
proc standard data= senrenameZscore mean=0 std=1
              out=senzscores5;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;

*FULL MODEL;
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
proc mixed data=senzscores1 noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale  svyedu (ref='1:Less than primary') ISO2(ref='BR');
model  obesity=svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR 
       BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnFullIsoSen1
           FitStatistics=FS_MmodelnFullIsoSen1
           CovParms=CP_MmodelnFullIsoSen1;
run;
proc mixed data=senzscores2 noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale  svyedu (ref='1:Less than primary') ISO2(ref='BR');
model  obesity=svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR 
       BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnFullIsoSen2
           FitStatistics=FS_MmodelnFullIsoSen2
           CovParms=CP_MmodelnFullIsoSen2;
run;
proc mixed data=senzscores3 noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale  svyedu (ref='1:Less than primary') ISO2(ref='BR');
model  obesity=svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR 
       BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnFullIsoSen3
           FitStatistics=FS_MmodelnFullIsoSen3
           CovParms=CP_MmodelnFullIsoSen3;
run;
proc mixed data=senzscores4 noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale  svyedu (ref='1:Less than primary') ISO2(ref='BR');
model  obesity=svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR 
       BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnFullIsoSen4
           FitStatistics=FS_MmodelnFullIsoSen4
           CovParms=CP_MmodelnFullIsoSen4;
run;
proc mixed data=senzscores5 noclprint empirical covtest PLOTS(MAXPOINTS=500000);
class salid1 salid2 svymale  svyedu (ref='1:Less than primary') country(ref='BR');
model  obesity=svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR 
       BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR country country*svyedu/ solution cl;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output SolutionF=PAR_MmodelnFullIsoSen5
           FitStatistics=FS_MmodelnFullIsoSen5
           CovParms=CP_MmodelnFullIsoSen5
		   tests3 = type3;
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

%ICCMOR (CP_Mmodelnfulliso, CP_Mmodelnfulliso_1)
%ICCMOR (CP_MmodelnfullisoSen1, CP_Mmodelnfulliso_1Sen1)
%ICCMOR (CP_MmodelnfullisoSen2, CP_Mmodelnfulliso_1Sen2)
%ICCMOR (CP_MmodelnfullisoSen3, CP_Mmodelnfulliso_1Sen3)
%ICCMOR (CP_MmodelnfullisoSen4, CP_Mmodelnfulliso_1Sen4)
%ICCMOR (CP_MmodelnfullisoSen5, CP_Mmodelnfulliso_1Sen5)
;
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

data PARestFullSen1;
set PAR_MmodelnfullisoSen1;

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
data PARestFullSen2;
set PAR_MmodelnfullisoSen2;

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
data PARestFullSen3;
set PAR_MmodelnfullisoSen3;

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

data PARestFullSen4;
set PAR_MmodelnfullisoSen4;

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
title;


ODS listing close;
ODS tagsets.ExcelXP file = ".....\output\BMI Model Full Sensitivity 01-11.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');
ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 1 Model");

title "Sensitivity analysis - AR dropped from model";
proc freq data = senanalysis1;
table iso2/ nopercent nocum;
run;

proc print data = ParEstFullSen1 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt Lower Upper;
run;
proc print data = FS_MmodelnFullIsoSen1 noobs; 
title "Fit Statistics";
run;
proc print data = CP_MmodelnFullIsoSen1 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen1 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen1 (firstobs = 5) label noobs; 
title "ICC";
Var subject ICC;
label ICC = "ICC";
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 2 Model");
title "Sensitivity analysis - BMI outliers removed";
proc means data = Senanalysis2 ;
var obesity;
class obesitycat;
run;

proc print data = ParEstFullSen2 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt Lower Upper;
run;
proc print data = FS_MmodelnFullIsoSen2 noobs; 
title "Fit Statistics";
run;
proc print data = CP_MmodelnFullIsoSen2 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen2 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen2 (firstobs = 5) label noobs;
title "ICC";
Var subject ICC;
label ICC = "ICC";
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 3 Model");
title "Sensitivity analysis - Recent survey years";
proc means data = Senanalysis3 ;
var obesity;
class obesitycat;
run;
proc print data = ParEstFullSen3 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt Lower Upper;
run;
proc print data = FS_MmodelnFullIsoSen3 noobs; 
title "Fit Statistics";
run;
proc print data = CP_MmodelnFullIsoSen3 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen3 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen3 (firstobs = 5) label noobs; 
title "ICC";
Var subject ICC;
label ICC = "ICC";
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 4 Model");
title "Sensitivity analysis - Within 3 standard deviations for population density";
proc means data = Senanalysis4 ;
var obesity;
class obesitycat;
run;
proc print data = ParEstFullSen4 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt Lower Upper;
run;
proc print data = FS_MmodelnFullIsoSen4 noobs; 
title "Fit Statistics";
run;
proc print data = CP_MmodelnFullIsoSen4 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen4 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen4 (firstobs = 5) label noobs; 
title "ICC";
Var subject ICC;
label ICC = "ICC";
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity Model 5");
title "Sensitivity Analysis - Interactions beween country and personal education.  
Central America is combined.";

proc freq data = senanalysis5;
table iso2*country/ nopercent nocum norow nocol;
run;
proc print data = PAR_MmodelnFullIsoSen5 noobs;
title "Paramater Estimates"; 
run;
proc print data =type3 noobs;
title "Interaction effects";
run;
proc print data = FS_MmodelnFullIsoSen5 noobs; 
title "Fit Statistics";
run;
proc print data = CP_MmodelnFullIsoSen5 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen5 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen5 (firstobs = 5) label noobs; 
title "ICC";
Var subject ICC;
label ICC = "ICC";
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Full Model");
title;
proc freq data = foranalysis;
table iso2/ nopercent nocum;
run;
proc means data = foranalysis ;
var obesity;
class obesitycat;
run;

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
label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1 (firstobs = 5) label noobs; 
title "ICC";
Var subject  ICC;
label ICC = "ICC";
run;
ods tagsets.excelxp close;
ods listing;

