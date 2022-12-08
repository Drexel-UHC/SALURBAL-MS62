/**********************************************************************
* Project           : MS62
*            		: Step 3B-Full models for Obesity
* Author            : CK
* Date created      : 06/24/2020
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

   svyage_10 = (svyage - 42.343181818) / 10;

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


ods graphics on;

*FULL MODEL ;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR 
BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_Mmodelnfulliso 
           FitStatistics=FS_Mmodelnfulliso
           CovParms=CP_Mmodelnfulliso
		   OddsRatios=OR_Mmodelnfulliso;
run;
proc print data = PAR_MmodelnFullIso;
run;


*Empty Model;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR');
model  obesityCat= svyage_10 svymale ISO2 /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_Mmodelnemptyiso 
           FitStatistics=FS_Mmodelnemptyiso
           CovParms=CP_Mmodelnemptyiso
		   OddsRatios=OR_Mmodelnemptyiso;
run;



%macro ICCMOR (data, datanew);
proc sql ;
create table icc as
select sum(estimate*(Subject='SALID1')) / (sum(estimate)+3.29) as iccL1AD, 
	   sum(estimate*(Subject='SALID2(SALID1)')) / (sum(estimate)+3.29) as iccL2, 
	   3.29/(sum(estimate)+3.29) as residualL1L2,
	   sum(estimate)/(sum(estimate)+3.29) as ICCL1L2,
	   (sum(estimate)+3.29) as denominator,
	   EXP(0.6745*SQRT(2*sum(estimate*(Subject='SALID1')))) as MOR1,
	   EXP(0.6745*SQRT(2*sum(estimate*(Subject='SALID2(SALID1)')))) as MOR2,
	   EXP(0.6745*SQRT(2*(sum(estimate)))) as MOR3,
	   sum(estimate) as L1L2_estSum

from &data ;
quit ;

proc transpose data = ICC out = TRICC
                              prefix = icc;
var ICCL1AD ICCL2 residualL1L2 denominator ICCL1L2 ICCL1AD;
run;
proc transpose data = ICC out = TRMOR
                           prefix = MOR;
var  MOR1 MOR2 MOR3;
run;
proc print data = trmor;run;

Data &datanew ;
  retain CovParm Subject Estimate StdErr  ICC  MOR;
  length subject $200.;
  merge TRICC TRMOR &data;

  icc = icc1;
  MOR = MOR1;
  drop _name_ icc1 MOR1;

  if _n_ = 3 then subject = "Residual" ;
  if _n_ = 3 then estimate = 3.29;
  if _n_ = 4 then subject = "Total Variance";
  if _n_ = 5 then subject = "Correlation among people in the same L2";
  if _n_ = 6 then subject = "Correlation among people in the same L1 but NOT the same L2";

  Label 
   ICC = "% of variation";
run;

proc print data = &datanew label;
run;
%mend;

ods graphics off;

%ICCMOR (CP_Mmodelnfulliso, CP_Mmodelnfulliso_1);
%ICCMOR (CP_Mmodelnemptyiso, CP_Mmodelnemptyiso_1);



* PARAMATER ESTIMATES;
 Data parEstFull;
  set PAR_Mmodelnfulliso;
	 length label $50.;

	 keep tValue Probt label estimate stderr; 


	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "svyage_10*svyage_10" then label = "svyage_10*svyage_10";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;


run;

Data ParEstEmpty;
 set PAR_Mmodelnemptyiso;

	 length label $50.;
	 keep tValue Probt type label estimate stderr; 

     if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
     else label = effect;

run;



ODS listing close;
ODS tagsets.ExcelXP file = "......\output\obesityCat FullModel 01-08.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Full Model");
proc print data = ParEstFull noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt;
run;
proc print data = FS_MmodelnFullIso noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnFullIso noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnFullIso noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
run;
proc print data = CP_MmodelnfullIso_1 (firstobs = 5) label noobs; 
title "ICC";
Var subject ICC;
label   ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1 (obs = 3) noobs;
title "MOR";
Var Estimate MOR;
run;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Empty Model");

proc print data = ParEstempty noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt;
run;
proc print data = FS_MmodelnemptyIso noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnemptyIso noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnemptyIso noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnemptyIso_1 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
run;
proc print data = CP_MmodelnemptyIso_1 (firstobs = 5)label noobs; 
title "ICC";
Var subject ICC;
label   ICC = "ICC";
run;
proc print data = CP_Mmodelnemptyiso_1 (obs = 3) noobs;
title "MOR";
Var Estimate MOR;
run;
ods tagsets.excelxp close;
ods listing;




