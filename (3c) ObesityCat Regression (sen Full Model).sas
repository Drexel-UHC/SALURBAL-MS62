/**********************************************************************
* Project           : MS62
*            		: Step 3C-Sensitivity models for Obesity
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
Data Senanalysis1;  
 set out.analysisObesityCAT;
 where exclude = 0 and iso2 ne "AR"; 
run;
Data Senanalysis2;  
 set out.analysisObesityCAT;
 where exclude = 0 and 12 < Obesity < 70 ; 
run;
Data Senanalysis3;  
 set out.analysisObesityCAT;
 where exclude = 0 and iso2 in ('AR', 'BR', 'CL', 'MX', 'PE');
run;
Data Senanalysis4;  
 set out.analysisObesityCat;
 where exclude = 0; 

 threesd = 7772.75+ (4414.24*3);

 if BECPOPDENSL2 le threesd then flagthree = 0;
 if BECPOPDENSL2 gt threesd then flagthree = 1;

 if flagthree = 0 then output;
run;
proc means data = Senanalysis4 mean std;
var BECPOPDENSL2 ;
run;

Data Senanalysis5;  
 set out.analysisObesityCat;
 where exclude = 0;

 if iso2 in ('PA','SV','GT','NI') then country = 'CA';
 else country = ISO2;
run;

*STANDARDIZE VARS;
 DATA renameZscore;
  SET foranalysis;

	BECADINTDENSL2_ZSCR = BECADINTDENSL2;
	BECMEDNDVINL2_ZSCR = BECMEDNDVINL2; 
	BECPOPDENSL2_ZSCR = BECPOPDENSL2;
	BECPOPDENSL1AD_ZSCR = BECPOPDENSL1AD;
	TPOPDENSL2_ZSCR = TPOPDENSL2;
	TPOPDENSL1AD_ZSCR = TPOPDENSL1AD;
	BECPOPDENSL2New_ZSCR = BECPOPDENSL2_new;
	BECPOPDENSL2Old_ZSCR = BECPOPDENSL2_old;
	CNSSE3_L2_ZSCR = CNSSE3_L2;
	BECPTCHDENSL1AD_ZSCR = BECPTCHDENSL1AD;
	BECPCTURBANL1AD_ZSCR = BECPCTURBANL1AD;
	BECAWMNNNGHL1AD_ZSCR = BECAWMNNNGHL1AD; 
	SVYAGE_ZSCR = SVYAGE;

  
   svyage_10 = (svyage - 42.343181818) / 10;


RUN;
proc standard data= renameZscore mean=0 std=1
              out=zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR BECPOPDENSL1AD_ZSCR BECPOPDENSL1AD_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR TPOPDENSL2_ZSCR TPOPDENSL1AD_ZSCR
    BECPOPDENSL2New_ZSCR BECPOPDENSL2Old_ZSCR;
run;
proc print data = zscores (obs = 20); run;
proc sort data = zscores; 
by descending obesityCat;
run;


******
SEN1;
*STANDARDIZE VARS;

 DATA renameZscore;
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
proc standard data= renameZscore mean=0 std=1
              out=sen1zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc sort data = sen1zscores; 
by descending obesityCat;
run;

****
SEN2;
*STANDARDIZE VARS;

 DATA renameZscore;
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
proc standard data= renameZscore mean=0 std=1
              out=sen2zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc sort data = sen2zscores; 
by descending obesityCat;
run;

****
SEN3;
*STANDARDIZE VARS;

 DATA renameZscore;
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
proc standard data= renameZscore mean=0 std=1
              out=sen3zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc sort data = sen3zscores; 
by descending obesityCat;
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
              out=sen4zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc sort data = sen4zscores; 
by descending obesityCat;
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
              out=sen5zscores;
var BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR CNSSE3_L2_ZSCR
    BECPTCHDENSL1AD_ZSCR BECPCTURBANL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR; 
run;
proc sort data = sen5zscores; 
by descending obesityCat;
run;


*FULL MODEL ;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= svyage_10 svyage_10*svyage_10 svymale svyedu CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_Mmodelnfulliso 
           FitStatistics=FS_Mmodelnfulliso
           CovParms=CP_Mmodelnfulliso
		   OddsRatios=OR_Mmodelnfulliso;
run;


**SENSITIVITY MODELS;
proc glimmix data=Sen1zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= svyage_10 svyage_10*svyage_10 svymale svyedu 
CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSen1 
           FitStatistics=FS_MmodelnfullisoSen1
           CovParms=CP_MmodelnfullisoSen1
		   OddsRatios=OR_MmodelnfullisoSen1;
run;
proc glimmix data=Sen2zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= svyage_10 svyage_10*svyage_10 svymale svyedu 
CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSen2 
           FitStatistics=FS_MmodelnfullisoSen2
           CovParms=CP_MmodelnfullisoSen2
		   OddsRatios=OR_MmodelnfullisoSen2;
run;
proc sort data = zscores; 
by descending Ovrwt_obesity_Cat;
run;
proc glimmix data=zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary');
model  Ovrwt_obesity_Cat= svyage_10 svyage_10*svyage_10 svymale svyedu 
CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR  ISO2  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_Mmodelnfullisosenx 
           FitStatistics=FS_Mmodelnfullisosenx
           CovParms=CP_Mmodelnfullisosenx
		   OddsRatios=OR_Mmodelnfullisosenx;
run;
proc glimmix data=Sen3zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= svyage_10 svyage_10*svyage_10 svymale svyedu 
CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSen3 
           FitStatistics=FS_MmodelnfullisoSen3
           CovParms=CP_MmodelnfullisoSen3
		   OddsRatios=OR_MmodelnfullisoSen3;
run;
proc glimmix data=Sen4zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale ISO2(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= svyage_10 svyage_10*svyage_10 svymale svyedu 
CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR ISO2  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSen4 
           FitStatistics=FS_MmodelnfullisoSen4
           CovParms=CP_MmodelnfullisoSen4
		   OddsRatios=OR_MmodelnfullisoSen4;
run;
proc glimmix data=Sen5zscores noclprint empirical=mbn method=LAPLACE order = data;
class salid1 salid2 svymale country(ref='BR') svyedu (ref='1:Less than primary');
model  obesityCat= svyage_10 svyage_10*svyage_10 svymale svyedu 
CNSSE3_L2_ZSCR BECPCTURBANL1AD_ZSCR BECADINTDENSL2_ZSCR BECMEDNDVINL2_ZSCR BECPOPDENSL2_ZSCR 
BECPTCHDENSL1AD_ZSCR BECAWMNNNGHL1AD_ZSCR country country*svyedu  /dist=bin link=logit solution or(label);
nloptions gconv=0.0000000001;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid1;
RANDOM INTERCEPT / TYPE=UN SUBJECT=salid2(salid1);
ods output ParameterEstimates=PAR_MmodelnfullisoSen5
           FitStatistics=FS_MmodelnfullisoSen5
           CovParms=CP_MmodelnfullisoSen5
		   OddsRatios=OR_MmodelnfullisoSen5
		   tests3=type3;
run;

**ADD ICC AND MOR;
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
run;

proc print data = &datanew label;
run;
%mend;

ods graphics off;

%ICCMOR (CP_Mmodelnfulliso, CP_Mmodelnfulliso_1)
%ICCMOR (CP_MmodelnfullisoSen1, CP_Mmodelnfulliso_1Sen1)
%ICCMOR (CP_MmodelnfullisoSen2, CP_Mmodelnfulliso_1Sen2)
%ICCMOR (CP_MmodelnfullisoSenx, CP_Mmodelnfulliso_1Senx)
%ICCMOR (CP_MmodelnfullisoSen3, CP_Mmodelnfulliso_1Sen3)
%ICCMOR (CP_MmodelnfullisoSen4, CP_Mmodelnfulliso_1Sen4)
%ICCMOR (CP_MmodelnfullisoSen5, CP_Mmodelnfulliso_1Sen5);

**RE-FORMAT PARAMATER ESTIMATES;
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
 Data parEstFullSen1;
  set PAR_MmodelnfullisoSen1;
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
 Data parEstFullSen2;
  set PAR_MmodelnfullisoSen2;
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
 Data parEstFullSenx;
  set PAR_MmodelnfullisoSenx;
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
 Data parEstFullSen3;
  set PAR_MmodelnfullisoSen3;
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
 Data parEstFullSen4;
  set PAR_MmodelnfullisoSen4;
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


ODS listing close;
ODS tagsets.ExcelXP file = ".....\output\obesityCat FullModel Sensitivity 12-08.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 1 Model");
title "Sensitivity analysis - AR dropped from model";
proc freq data = Senanalysis1 ;
table iso2 / nocum nopercent;
run;
proc print data = ParEstFullSen1 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt;
run;
proc print data = FS_MmodelnFullIsoSen1 noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnFullIsoSen1 noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnFullIsoSen1 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen1 (obs =3) label noobs; 
title "% Variation";
Var subject estimate ICC;
Label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen1 (firstobs = 5)label noobs;
title "ICC";
Var subject ICC;
Label ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1Sen1 (obs =3) noobs;
title "MOR";
Var Estimate MOR;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 2 Model");
title "Sensitivity analysis - BMI outliers removed";
proc means data = sen2zscores order = data;
var obesity;
class obesitycat;
run;
proc print data = ParEstFullSen2 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt;
run;
proc print data = FS_MmodelnFullIsoSen2 noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnFullIsoSen2 noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnFullIsoSen2 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen2 (obs =3) label noobs; 
title "% Variation";
Var subject estimate ICC;
Label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen2 (firstobs = 5)label noobs;
title "ICC";
Var subject ICC;
Label ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1Sen2 (obs =3) noobs;
title "MOR";
Var Estimate MOR;
run;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 3 Model");
title "Sensitivity analysis - Overweight and Obesity Combined";
proc means data = zscores order = data;
var obesity;
class Ovrwt_obesity_cat;
run;
proc print data = ParEstFullSenx noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt;
run;
proc print data = FS_MmodelnFullIsoSenx noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnFullIsoSenx noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnFullIsoSenx noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Senx (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
Label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Senx (firstobs = 5)label noobs;
title "ICC";
Var subject ICC;
Label ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1Senx (obs =3) noobs;
title "MOR";
Var Estimate MOR;
run;



ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 4 Model");
title "Sensitivity analysis - Recent Survey years";
proc freq data = Senanalysis3;
table iso2 / nopercent nocum;
run;
proc print data = ParEstFullSen3 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt;
run;
proc print data = FS_MmodelnFullIsoSen3 noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnFullIsoSen3 noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnFullIsoSen3 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen3 (obs = 3) label noobs; 
title "% Variation";
Var subject estimate ICC;
Label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen3 (firstobs = 5)label noobs;
title "ICC";
Var subject ICC;
Label ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1Sen3 (obs =3) noobs;
title "MOR";
Var Estimate MOR;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity 5 Model");
title "Sensitivity analysis - Within 3 st.dev. for population density";
proc freq data = Senanalysis4;
table iso2/ nopercent nocum;
run;
proc print data = ParEstFullSen4 noobs;
title "Paramater Estimates"; 
var label Estimate StdErr tValue Probt;
run;
proc print data = FS_MmodelnFullIsoSen4 noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnFullIsoSen4 noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnFullIsoSen4 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen4 (obs =3) label noobs; 
title "% Variation";
Var subject estimate ICC;
Label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen4(firstobs = 5)label noobs;
title "ICC";
Var subject  ICC;
Label ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1Sen4 (obs =3) noobs;
title "MOR";
Var Estimate MOR;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sensitivity Model 6");
title "Sensitivity Analysis - Interactions beween country and personal education.  Central America is combined.";
proc freq data = Senanalysis5 ;
table iso2*country / nopercent nocum norow nocol;
run;
proc print data = PAR_MmodelnfullisoSen5 noobs;
title "Paramater Estimates"; 
run;
proc print data =type3 noobs;
title "Interaction effects";
run;
proc print data = FS_MmodelnFullIsoSen5 noobs; 
title "Fit Statistics";
run;
proc print data = OR_MmodelnFullIsoSen5 noobs; 
title "Odds Ratio";
var label Estimate Lower Upper;
run;
proc print data = CP_MmodelnFullIsoSen5 noobs; 
title "Covariance";
run;
proc print data = CP_MmodelnfullIso_1Sen5 (obs =3) label noobs; 
title "% Variation";
Var subject estimate ICC;
Label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1Sen5 (firstobs = 5) label noobs;  
title "ICC";
Var subject ICC;
Label ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1Sen5 (obs =3) noobs;
title "MOR";
Var Estimate MOR;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Full Model");
title;
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
proc print data = CP_MmodelnfullIso_1 (obs =3) label noobs; 
title "% Variation";
Var subject estimate ICC;
Label ICC = "% of variation";
run;
proc print data = CP_MmodelnfullIso_1 (firstobs = 5)label noobs;
title "ICC";
Var subject ICC;
Label ICC = "ICC";
run;
proc print data = CP_Mmodelnfulliso_1  (obs =3) noobs;
title "MOR";
Var Estimate MOR;
run;
ods tagsets.excelxp close;
ods listing;




