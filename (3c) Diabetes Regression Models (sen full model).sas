/**********************************************************************
* Project           : MS62
*            		: Step 3C-Sensitivity models for Diabetes
* Author            : CK
* Date created      : 06/17/2020
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
 set out.analysisDiabetes;
 where exclude = 0;
run;
proc means data = foranalysis;
var svyage;
run;
Data senanalysis;
 set out.analysisDiabetes;
 where exclude = 0 and ISO2 ne 'PA';
run;
proc means data = senanalysis;
var svyage;
run;
Data Senanalysis2;
set out.analysisDiabetes;
where exclude = 0 and iso2 in ('AR', 'BR', 'CL', 'MX', 'PE');
run;
proc means data = senanalysis2;
var svyage;
run;
Data Senanalysis3;
set out.analysisDiabetes;
where exclude = 0;

 threesd = 8244.27+ (4875.50*3);

 if BECPOPDENSL2 le threesd then flagthree = 0;
 if BECPOPDENSL2 gt threesd then flagthree = 1;

 if flagthree = 0 then output;
run;
proc means data = senanalysis3 mean std;
var svyage;
run;
proc means data = senanalysis3 mean std;
var BECPOPDENSL2;
run;


Data Senanalysis4; *Combine Central America;
set out.analysisDiabetes;
where exclude = 0;
 if iso2 in ('PA','SV','GT','NI') then country = 'CA';
 else country = ISO2;
run;
proc means data = senanalysis4;
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

    svyage_10 = (svyage - 42.6260157)/ 10;

RUN;
proc standard data= renameZscore mean=0 std=1
              out=zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR
	;
run;
proc print data = zscores (obs = 20); run;
proc sort data = zscores; 
by descending diabetes;
run;


**SENSITIVITY
*STANDARDIZE VARS;

 DATA SENrenameZscore;
  SET SENanalysis;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

   svyage_10 = (svyage - 42.7511786)/ 10;

RUN;
proc standard data= SENrenameZscore mean=0 std=1
              out=SENzscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc print data = SENzscores (obs = 20); run;
proc sort data = SENzscores; 
by descending diabetes;
run;
DATA SENrenameZscore;
  SET SENanalysis2;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

    svyage_10 = (svyage - 43.5324496)/ 10;

RUN;
proc standard data= SENrenameZscore mean=0 std=1
              out=SENzscores2;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc print data = SENzscores2 (obs = 20); run;
proc sort data = SENzscores2; 
by descending diabetes;
run;
DATA SENrenameZscore;
  SET SENanalysis3;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

    svyage_10 = (svyage - 42.6195954)/ 10;

RUN;
proc standard data= SENrenameZscore mean=0 std=1
              out=SENzscores3;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc print data = SENzscores3 (obs = 20); run;
proc sort data = SENzscores3; 
by descending diabetes;
run;
 DATA SENrenameZscore;
  SET SENanalysis4;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 

    svyage_10 = (svyage - 42.6260157)/ 10;

RUN;
proc standard data= SENrenameZscore mean=0 std=1
              out=SENzscores4;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc print data = SENzscores4 (obs = 20); run;
proc sort data = SENzscores4; 
by descending diabetes;
run;

*Full Model ;
ods graphics on;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary') ;
model  diabetes= svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR 
                 BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2 
                 /dist=bin link=logit solution or(label) ;
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_Mmodelnfulliso 
           FitStatistics=FS_Mmodelnfulliso
           CovParms=CP_Mmodelnfulliso
		   OddsRatios=OR_Mmodelnfulliso;
run;

*SEN  Models;
proc glimmix data=SENzscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary') ;
model  diabetes= svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR 
                 BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2 
                 /dist=bin link=logit solution or(label) ;
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSEN 
           FitStatistics=FS_MmodelnfullisoSEN
           CovParms=CP_MmodelnfullisoSEN
		   OddsRatios=OR_MmodelnfullisoSEN;
run;
proc glimmix data=SENzscores2 noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary') ;
model  diabetes= svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR 
                 BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2 
                 /dist=bin link=logit solution or(label) ;
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSEN2 
           FitStatistics=FS_MmodelnfullisoSEN2
           CovParms=CP_MmodelnfullisoSEN2
		   OddsRatios=OR_MmodelnfullisoSEN2;
run;
proc glimmix data=SENzscores3 noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary') ;
model  diabetes= svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR 
                 BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2 
                 /dist=bin link=logit solution or(label) ;
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSEN3 
           FitStatistics=FS_MmodelnfullisoSEN3
           CovParms=CP_MmodelnfullisoSEN3
		   OddsRatios=OR_MmodelnfullisoSEN3;
run;
proc glimmix data=Senzscores4 noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale country(ref='BR') svyedu (ref='1:Less than primary') ;
model  diabetes= svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR 
                 BECPOPDENSL2_ZSCR BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR country country*svyedu 
                 /dist=bin link=logit solution or(label) ;
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSen4 
           FitStatistics=FS_MmodelnfullisoSen4
           CovParms=CP_Mmodelnfullisosen4
		   OddsRatios=OR_MmodelnfullisoSen4
		   tests3 = type3;
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


Data &datanew ;

length subject $200.;
retain CovParm Subject Estimate StdErr  ICC  MOR;

  merge TRICC TRMOR &data;

  icc = icc1;
  MOR = MOR1;
  drop _name_ icc1 MOR1;

 if _n_ = 3 then subject = "Residual" ;
 if _n_ = 3 then estimate = 3.29;
 if _n_ = 4 then subject = "Total Variance";
 if _n_ = 5 then subject = "Correlation among people in the same L2";
 if _n_ = 6 then subject = "Correlation among people in the same L1 but NOT the same L2";

run;


%mend;

ods graphics off;

%ICCMOR (CP_Mmodelnfulliso, CP_Mmodelnfulliso_1)
%ICCMOR (CP_MmodelnfullisoSEN, CP_Mmodelnfulliso_1SEN)
%ICCMOR (CP_MmodelnfullisoSEN2, CP_Mmodelnfulliso_1SEN2)
%ICCMOR (CP_MmodelnfullisoSEN3, CP_Mmodelnfulliso_1SEN3)
%ICCMOR (CP_MmodelnfullisoSEN4, CP_Mmodelnfulliso_1SEN4)
;


Data ParEstFull;
 set PAR_Mmodelnfulliso;

	 length label $50.;

	 keep  tValue Probt label estimate stderr; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;
run;



Data ParEstFullSEN;
 set PAR_MmodelnfullisoSEN;

	 length label $50.;

	 keep tValue Probt label estimate stderr; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;
run;


Data ParEstFullSEN2;
 set PAR_MmodelnfullisoSEN2;

	 length label $50.;

	 keep tValue Probt label estimate stderr; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;
run;
Data ParEstFullSEN3;
 set PAR_MmodelnfullisoSEN3;

	 length label $50.;

	 keep tValue Probt label estimate stderr; 

	 if effect = "SVYMALE" and SVYMALE = 1 then Label = "SVYMALE 1:Male";
	 else if effect = "SVYMALE" and SVYMALE = 0 then Label = "SVYMALE 0:Female";
	 else if effect = "SVYEDU" and SVYEDU = 1 then label = "SVYEDU 1:Less than primary";
	 else if effect = "SVYEDU" and SVYEDU = 2 then label = "SVYEDU 2:Primary";
	 else if effect = "SVYEDU" and SVYEDU = 3 then label = "SVYEDU 3:Secondary";
	 else if effect = "SVYEDU" and SVYEDU = 4 then label = "SVYEDU 4:University";
	 else if effect = "ISO2" then label = CATX (":", effect, ISO2);
	 else label = effect;
run;


ODS listing close;
ODS tagsets.ExcelXP file = ".....\output\Diabetes sensitivity 01-11.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity Model 1");
title "Sensitivity analysis - PA dropped from model";
proc freq data = SENanalysis;
table iso2 /nopercent nocum;
run;
proc print data=ParEstFullSEN noobs;
title "Paramater Estimates";
var label Estimate StdErr tValue Probt; 
run;
proc print data=FS_MmodelnfullisoSEN noobs;
title "Fit Statistics";
run;
proc print data=OR_MmodelnfullisoSEN noobs;
title "Odds Ratio";
var Label Estimate Lower Upper ;
run;
proc print data = CP_MmodelnFullIsoSEN noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnFullIso_1SEN (obs = 3) label noobs; 
title "% Variance";
var subject Estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnFullIso_1SEN (firstobs = 5) label noobs; 
title "ICC";
var subject ICC;
label ICC = "ICC";
run;
proc print data = CP_MmodelnFullIso_1SEN (obs =3) noobs; 
title "MOR";
var Estimate MOR;
run;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity Model 2");
title "Sensitivity analysis - Recent Survey Years";
proc freq data = SENzscores2;
table iso2 /nopercent nocum;
run;
proc print data=ParEstFullSEN2 noobs;
title "Paramater Estimates";
var label Estimate StdErr tValue Probt; 
run;
proc print data=FS_MmodelnfullisoSEN2 noobs;
title "Fit Statistics";
run;
proc print data=OR_MmodelnfullisoSEN2 noobs;
title "Odds Ratio";
var Label Estimate Lower Upper ;
run;
proc print data = CP_MmodelnFullIsoSEN2 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnFullIso_1SEN2 (obs = 3) label noobs; 
title "%Variance";
var subject Estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnFullIso_1SEN2 (firstobs = 5) label noobs; 
title "ICC";
var subject ICC;
label ICC = "ICC";
run;
proc print data = CP_MmodelnFullIso_1SEN2 (obs =3) noobs; 
title "MOR";
var Estimate MOR;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity Model 3");
title "Sensitivity - Population density greater than three standard deviations removed";
proc freq data = SENzscores3;
table iso2 /nopercent nocum;
run;
proc print data=ParEstFullSEN3 noobs;
title "Paramater Estimates";
var label Estimate StdErr tValue Probt; 
run;
proc print data=FS_MmodelnfullisoSEN3 noobs;
title "Fit Statistics";
run;
proc print data=OR_MmodelnfullisoSEN3 noobs;
title "Odds Ratio";
var Label Estimate Lower Upper ;
run;
proc print data = CP_MmodelnFullIsoSEN3 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnFullIso_1SEN3 (obs = 3) label noobs; 
title "%Variance";
var subject Estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnFullIso_1SEN3 (firstobs = 5) label noobs; 
title "ICC";
var subject ICC;
label ICC = "ICC";
run;
proc print data = CP_MmodelnFullIso_1SEN3 (obs =3) noobs; 
title "MOR";
var Estimate MOR;
run;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity Model 4");
title "Sensitivity Analysis - Interactions beween country and personal education.  
Central America is combined.";
proc freq data = SENanalysis4;
table iso2*country /nopercent nocum norow nocol;
run;
proc print data = PAR_MmodelnfullisoSEN4 noobs;
title "Paramater Estimates";
run;
proc print data =type3 noobs;
title "Interaction effects";
run;
proc print data=FS_MmodelnfullisoSEN4 noobs;
title "Fit Statistics";
run;
proc print data=OR_MmodelnfullisoSEN4 noobs;
title "Odds Ratio";
var Label Estimate Lower Upper ;
run;
proc print data = CP_MmodelnFullIsoSEN4 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnFullIso_1SEN4 (obs = 3) label noobs; 
title "% Variance";
var subject Estimate ICC;
label ICC = "% of variation";
run;
proc print data = CP_MmodelnFullIso_1SEN4 (firstobs = 5) label noobs;  
title "ICC";
var subject ICC;
label ICC = "ICC";
run;
proc print data = CP_MmodelnFullIso_1SEN4 (obs =3) noobs; 
title "MOR";
var Estimate MOR;
run;
ods tagsets.excelxp close;
ods listing;
