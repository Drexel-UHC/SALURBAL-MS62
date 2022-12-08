
/**********************************************************************
* Project           : MS62
*            		: Step 1-prepare analytic dataset
* Author            : CK
* Date created      : 03/11/2020
* Last run          : 11/02/2020
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
  1 = "Yes"
  0 = "No"
  9999 = "Missing";

 Value popDen
	1 = "Pop density Q1 (low)"
	2 = "Pop density Q2 (mid low)"
	3 = "Pop density Q3 (mid-high)"
	4 = "Pop density Q4 (high)";


value missing
  . = "Missing"
  other = "Populated";
run;


*READ IN BUILD ENV.;
PROC IMPORT OUT= WORK.becL2
            DATAFILE= "....\BEC_L2_20210104.csv" 
	        DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows = 1000;
RUN;
*OLD;
 PROC IMPORT OUT= WORK.becL2OLD
       DATAFILE="....\BEC_L2_20200506.csv"
       	    DBMS=CSV REPLACE;
            GETNAMES=YES;
            DATAROW=2;
			guessingrows = 10000
;
 RUN;
data BECL2Old;
 set BECL2old;
 keep BECPOPDENSL2 SALID2 SALID1;
 rename  BECPOPDENSL2=BECPOPDENSL2V1; ***NOT USING.  THIS WAS WHEN WE WERE CHECKING THE NEW POP DENS VARIABLE;

run;

PROC IMPORT OUT= WORK.becL1AD
            DATAFILE= "....\BEC_L1AD_20210104.csv" 
	        DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows = 1000;
RUN;
proc sort data = becL2; 
by salid1;
run;
proc sort data = becL1AD; 
by salid1;
run;
data BEC;
 merge becL2
       becL1AD;
 by SALID1;

 if iso2 = "NI"  then BECPOPDENSL2V3 = BECPOPDENS2005L2 ;  *NI matches to 2005;
 else BECPOPDENSL2V3 = BECPOPDENS2010L2 ; 

 if iso2 = "NI"  then BECPOPDENSL1ADV3 = BECPOPDENS2005L1AD ;  *NI matches to 2005;
 else BECPOPDENSL1ADV3 = BECPOPDENS2010L1AD ; 

run;
proc contents data = bec; run;
proc sort data = bec; 
by salid2;
run;
proc print data = bec;
where iso2= "GT";
run;
data BEC;
 merge bec
       becL2old;
 by SALID2;
run;
proc print data = BEC (obs = 100);run;



*READ IN L2 SOC ENV.;
PROC IMPORT OUT= WORK.sec
            DATAFILE= "....\SEC_INDEXSCORES_L2_08032020.csv" 
	        DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
Data  SEC;
  set SEC;
  if ISO2 = "PE" and year = "2007" then delete;
run;
proc sort data = sec (keep = iso2 year salid1 salid2 CNSSE3_L2) nodupkey 
        dupout = _2017; *2017 years CL;
by salid2;
run;
proc freq data = _2017; 
table iso2*year /list missing;
run;
proc freq data = SEC; 
table iso2*year /list missing;
run;


*READ IN ALL SURVEY FILES;
%macro read (country, datafile);
PROC IMPORT OUT= WORK.&country
            DATAFILE= "....\Survey Data\&datafile..csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows = 1000;
RUN;

data &country;
 set &country;
 drop SALMAID1 MATCHQUALITYMA SALMBID1 MATCHQUALITYMB;
run;

proc sort data = &country;
by SALSVYID;
run;


%mend;
%read (AR, AR_ENFR2013_12142020);
%read (BR, BR_PNS2013_12172020);
%read (CL, CL_ENS2010_12222020);
options  mprint = off;

%read (CO, CO_ENS2007_12142020);
%read (CR, CR_CAMDI2005_10232020);
%read (GT, GT_CAMDI2002_12172020);
%read (MX, MX_ENSANUT2012_12182020);
%read (NI, NI_CAMDI2003_10232020);
%read (PA, PA_ENSCAVI2007_10232020);
%read (PE, PE_ENDES2016_12182020);
%read (SV, SV_ENECA2014_12142020);
proc freq data = cl;
table SALID2/ out = n;
run;



Data survey_combined;
 set ar br cl co cr gt mx ni pa pe sv;
 keep SALSVYID SALID1 SALID2 SVYYEAR ISO2 SVYMALE SVYAGE SVYAGECAT SVYWTKGSELF SVYHTCMSELF SVYBMISELF	
      SVYBMICATSELF SVYDBDX1 SVYDBDX2 SVYEDU SVYWTKG SVYHTCM SVYBMI SVYBMICAT OBESITYCAT OVRWT_OBESITY_CAT 
      DIABETES OBESITY BMICAT SVYEX_EXCLUDE;
 length OBESITYCAT  8.0
        OBESITY     8.0
		DIABETES    8.0;

/* Create variable for diabetes outcome measure*/
	if iso2 ne "PA" then do;
	   DIABETES=SVYDBDX1;
	end;
	if iso2 eq "PA" then do;
	   DIABETES=SVYDBDX2;
	end;


/* Create variable for obesity continuous outcome measure*/
	if iso2 not in ("PA", "AR") then do;
	   OBESITY=SVYBMI;
	   BMICAT = SVYBMICAT;
	end;

	if iso2 eq "AR" then do;
	   OBESITY=SVYBMISELF;
	   BMICAT = SVYBMICATSELF;
	end;

   if iso2 eq "PA" then do;
	   OBESITY=9999;
	   BMICAT = 9999;
	end;


/* Create variable for obesity categorical outcome measure*/
	if iso2 not in ("PA", "AR") then do;
	   if SVYBMICAT = 4 then OBESITYCAT=1;
	   else if SVYBMICAT in (1,2,3) then OBESITYCAT= 0;
	   else OBESITYCAT = 9999;
	end;

	if iso2 eq "AR" then do;
	   	if SVYBMICATSELF = 4 then OBESITYCAT=1;
	    else if SVYBMICATSELF in (1,2,3) then OBESITYCAT= 0;
	    else OBESITYCAT = 9999;
	end;

	if iso2 eq "PA" then do;
	   OBESITYCAT=9999;
	end;


 /* Create variable for overweight + obesity in sensitivity analysis*/
	if iso2 not in ("PA", "AR") then do;
	   if SVYBMICAT in (3,4) then OVRWT_OBESITY_CAT=1;
	   else if SVYBMICAT in (1,2) then OVRWT_OBESITY_CAT= 0;
	   else OVRWT_OBESITY_CAT = 9999;
	end;

	if iso2 eq "AR" then do;
	   	if SVYBMICATSELF in (3,4) then OVRWT_OBESITY_CAT=1;
	    else if SVYBMICATSELF in (1,2) then OVRWT_OBESITY_CAT= 0;
	    else OVRWT_OBESITY_CAT = 9999;
	end;

	if iso2 eq "PA" then do;
	   OVRWT_OBESITY_CAT =9999;
	end;



/* create variable for missing data in survey exposure categories */
	 if SVYMALE gt 9000     then SVYEX_EXCLUDE = 1;
	 else if SVYAGE gt 9000 then SVYEX_EXCLUDE = 1;
	 else if SVYEDU gt 9000 then SVYEX_EXCLUDE = 1; else SVYEX_EXCLUDE = 0;


	 format svyedu SVYEDUfmt.
	        svymale SVYmalefmt.
			SVYAGECAT SVYAGECATfmt.
			bmicat svybmicatfmt.
            DIABETES
            OBESITYCAT 
            OVRWT_OBESITY_CAT yesno.;
run;
proc contents data = survey_combined; run;
proc print data = survey_combined (obs = 10); run;
proc sort data = survey_combined; 
by salid2;
run;
Data analytic_file 
     dropped_survey
     dropped_bec;
  merge survey_combined (in =a)
	    bec (in =b)
        sec (in = c);
  by salid2;

*Match NDVI with survey year;
	if SVYYEAR =      2002 then BECMEDNDVINL2 = BECMEDNDVINW2002L2 ;
	else if SVYYEAR = 2003 then BECMEDNDVINL2 = BECMEDNDVINW2003L2 ;
	else if SVYYEAR = 2005 then BECMEDNDVINL2 = BECMEDNDVINW2005L2;
	else if SVYYEAR = 2007 then BECMEDNDVINL2 = BECMEDNDVINW2007L2;
	else if SVYYEAR = 2010 then BECMEDNDVINL2 = BECMEDNDVINW2010L2 ;
	else if SVYYEAR = 2012 then BECMEDNDVINL2 = BECMEDNDVINW2012L2 ;
	else if SVYYEAR = 2013 then BECMEDNDVINL2 = BECMEDNDVINW2013L2 ;
	else if SVYYEAR = 2014 then BECMEDNDVINL2 = BECMEDNDVINW2014L2 ;
	else if SVYYEAR = 2016 then BECMEDNDVINL2 = BECMEDNDVINW2016L2 ;


*Match population density with survey year;
	if ISO2 = 'GT' then BECPOPDENSL2 = BECPOPDENS2009L2 ;  *GT matches to 2009 - first year available;
    else if ISO2 = 'NI' then BECPOPDENSL2 = BECPOPDENS2005L2 ;  *NI matches to 2005;
	else if ISO2 = 'PA' then BECPOPDENSL2 = BECPOPDENS2010L2 ;  *PA matches to 2010;
	else if ISO2 = 'CR' then BECPOPDENSL2  = BECPOPDENS2010L2 ; *CR matches to 2010;
	else if SVYYEAR = 2003 then BECPOPDENSL2  = BECPOPDENS2003L2 ;
	else if SVYYEAR = 2005 then BECPOPDENSL2  = BECPOPDENS2005L2 ;
	else if SVYYEAR = 2007 then BECPOPDENSL2  = BECPOPDENS2007L2 ;  
    else if SVYYEAR = 2010 then BECPOPDENSL2  = BECPOPDENS2010L2 ;
	else if SVYYEAR = 2012 then BECPOPDENSL2  = BECPOPDENS2012L2 ;
	else if SVYYEAR = 2013 then BECPOPDENSL2  = BECPOPDENS2013L2 ;
	else if SVYYEAR = 2014 then BECPOPDENSL2  = BECPOPDENS2014L2 ;
	else if SVYYEAR = 2016 then BECPOPDENSL2  = BECPOPDENS2016L2 ;

*Match population density with survey year;
	if ISO2 = 'GT' then BECPOPDENSL1AD = BECPOPDENS2009L1AD ;  *GT matches to 2009 - first year available;
    else if ISO2 = 'NI' then BECPOPDENSL1AD = BECPOPDENS2005L1AD ;  *NI matches to 2005;
	else if ISO2 = 'PA' then BECPOPDENSL1AD = BECPOPDENS2010L1AD ;  *PA matches to 2010;
	else if ISO2 = 'CR' then BECPOPDENSL1AD  = BECPOPDENS2010L1AD ; *CR matches to 2010;
	else if SVYYEAR = 2003 then BECPOPDENSL1AD  = BECPOPDENS2003L1AD ;
	else if SVYYEAR = 2005 then BECPOPDENSL1AD  = BECPOPDENS2005L1AD ;
	else if SVYYEAR = 2007 then BECPOPDENSL1AD  = BECPOPDENS2007L1AD ;  
    else if SVYYEAR = 2010 then BECPOPDENSL1AD  = BECPOPDENS2010L1AD ;
	else if SVYYEAR = 2012 then BECPOPDENSL1AD  = BECPOPDENS2012L1AD ;
	else if SVYYEAR = 2013 then BECPOPDENSL1AD  = BECPOPDENS2013L1AD ;
	else if SVYYEAR = 2014 then BECPOPDENSL1AD  = BECPOPDENS2014L1AD ;
	else if SVYYEAR = 2016 then BECPOPDENSL1AD  = BECPOPDENS2016L1AD ;


*Create new population density with total area - L2;
	*if ISO2 = 'NI' then TPOPDENSL2 = divide(BECTPOP2005L2,BECADAREAL2)*100;  *NI matches to 2005;
	*else TPOPDENSL2 = divide(BECTPOP2010L2,BECADAREAL2)*100;


*Create new population density with total area -L1AD;
	*if ISO2 = 'NI' then TPOPDENSL1AD = divide(BECTPOP2005L1AD,BECADAREAL1AD)*100;  *NI matches to 2005;
	*else TPOPDENSL1AD = divide(BECTPOP2010L1AD,BECADAREAL1AD)*100;

    popdenyr=svyyear;
	if ISO2 = 'GT' then popdenyr=2009;
    else if ISO2 = 'NI' then popdenyr=2005;
	else if ISO2 = 'PA' then popdenyr=2010;
	else if ISO2 = 'CR' then popdenyr=2010;


*Combine Subway vars into one;
*if BECPRSBRTL1AD =1 or BECPRSSUBWAYL1AD =1 then BRTSUBWAYL1AD = 1;
*else BRTSUBWAYL1AD =0;

*BEC_MISSING_COUNT=0;
*BEC_MISSING=0;



*Count BEC missingness;
array BEC {*} BECADINTDENSL2 BECMEDNDVINL2 BECPOPDENSL2 BECPTCHDENSL1AD BECPCTURBANL1AD BECAWMNNNGHL1AD;
do i=1 to dim(BEC);
	if BEC[i] = . then do;
	 BEC_MISSING_COUNT+1;
	 BEC_MISSING=1;
    end;
end;
drop i;

if CNSSE3_L2 = . then SEC_MISSING = 1;
else SEC_MISSING = 0;

*if APSPM25MEANL2 = 999998 then air_missing = 1;
*else air_missing = 0;


label 
Obesity = "BMI"
BECADINTDENSL2 = "Intersection Density L2"
BECPOPDENSL2  = "Population Density L2"
BECPOPDENSL1AD  = "Population Density L1AD"
BECMEDNDVINL2 = "Median of Annual Maximum NDVI L2"
CNSSE3_L2 = "SEC Factor Ana L2"
BECPTCHDENSL1AD = "Patch Density L1AD"
BECPCTURBANL1AD = "Percent Urban L1AD"
BECAWMNNNGHL1AD = "Urban Landscape, Isolation L1AD";

if a and b and c then output analytic_file; *242,481;  *Prev - 242,068 obs;
else if a then output dropped_survey;
else if b then output dropped_BEC;
run;
proc print data = dropped_bec (obs = 20);
run;
proc freq data = dropped_bec noprint;
table SALID2 / out=Ncheck;
run;
proc freq data = analytic_file noprint;
table SALID2 / out=Ncheck2;
run;
proc freq data = analytic_file;
table ISO2*popdenyr;
run;
proc freq data = dropped_survey;
table ISO2;
run;


**Create Analysis Files for each outcome;

Data out.AnalysisDiabetes;
 set analytic_file;

 if DIABETES not in (0,1) then OUT_EXCLUDE = 1;
 else OUT_EXCLUDE = 0;

 if OUT_EXCLUDE =1         then EXCLUDE =1;
 else if SVYEX_EXCLUDE =1  then EXCLUDE =1;
 else if BEC_MISSING =1    then EXCLUDE =1;
 else if SEC_MISSING =1    then EXCLUDE =1; else EXCLUDE =0;

 if BECPOPDENSL2 LE 4740.220402 then POPDENQUARTILE = 1; **SEE PROC MEANS BELOW;
 else if BECPOPDENSL2 LE 6735.804594 then POPDENQUARTILE = 2;
 else if BECPOPDENSL2 LE 10512.182812 then POPDENQUARTILE = 3;
 else if BECPOPDENSL2 LE 39498.669941 then POPDENQUARTILE = 4;

 label exclude = "Sample Size"
       POPDENQUARTILE = "Population Density Quartiles";

 format exclude sample.
		PopDenQuartile popden.;

 keep SALSVYID SALID1 SALID2 SVYYEAR ISO2	
      SVYMALE SVYAGE SVYAGECAT SVYWTKGSELF SVYHTCMSELF SVYDBDX1 SVYDBDX2 SVYEDU SVYWTKG SVYHTCM DIABETES
      BECPOPDENSL2  BECPOPDENSL1AD /*TPOPDENSL2 TPOPDENSL1AD*/ BECPOPDENSL2V3 BECPOPDENSL1ADV3 BECPOPDENSL2V1 BECPOPDENS2010L2 
      popdenyr BECADINTDENSL2 CNSSE3_L2	BECMEDNDVINL2 POPDENQUARTILE EXCLUDE OUT_EXCLUDE SVYEX_EXCLUDE BEC_MISSING SEC_MISSING
	  BECPTCHDENSL1AD BECPCTURBANL1AD BECAWMNNNGHL1AD;





 run;  ** OBS 242,481 ---OLD version 242,068 obs;
proc means data = out.AnalysisDiabetes min q1 median q3 max maxdec = 6;
var BECPOPDENSL2 ;
where exclude = 0;
run;


Data out.AnalysisObesity;
 set analytic_file;

 if OBESITY GE 9000 then OUT_EXCLUDE =1;
 else OUT_EXCLUDE =0;

 if OUT_EXCLUDE =1         then EXCLUDE =1;
 else if SVYEX_EXCLUDE =1  then EXCLUDE =1;
 else if BEC_MISSING =1    then EXCLUDE =1;
 else if SEC_MISSING =1    then EXCLUDE =1; else EXCLUDE =0;

 if BECPOPDENSL2 LE 4537.538988        then POPDENQUARTILE = 1; **PROC MEANS BELOW;
 else if BECPOPDENSL2 LE 6252.312257   then POPDENQUARTILE = 2;
 else if BECPOPDENSL2 LE 10025.433955  then POPDENQUARTILE = 3;
 else if BECPOPDENSL2 LE 30066.566425  then POPDENQUARTILE = 4;
 
 label exclude = "Sample Size"
       POPDENQUARTILE = "Population Density Quartiles";

 format exclude sample.
		PopDenQuartile popden.;

 keep SALSVYID	SALID1	SALID2	SVYYEAR	ISO2 SVYMALE SVYAGE	SVYAGECAT SVYWTKGSELF SVYHTCMSELF SVYBMISELF SVYBMICATSELF	
      SVYEDU SVYWTKG SVYHTCM SVYBMI	SVYBMICAT OBESITYCAT OBESITY BMICAT	
      BECPOPDENSL2 BECPOPDENSL1AD /*TPOPDENSL2 TPOPDENSL1AD*/ BECPOPDENSL2V3 BECPOPDENSL1ADV3 BECPOPDENSL2V1 BECPOPDENS2010L2 popdenyr BECADINTDENSL2	
      BECPCTURBANL1AD	BECPTCHDENSL1AD	BECAWMNNNGHL1AD	BECPRSBRTL1AD BECPRSSUBWAYL1AD	
      CNSSE3_L2	BECMEDNDVINL2 POPDENQUARTILE EXCLUDE OUT_EXCLUDE SVYEX_EXCLUDE BEC_MISSING SEC_MISSING
      BECPTCHDENSL1AD BECPCTURBANL1AD BECAWMNNNGHL1AD;
 run; **242,481;
proc means data = out.AnalysisObesity min q1 median q3 max maxdec=6;
var BECPOPDENSL2 ;
where exclude = 0;
run;


Data out.AnalysisObesityCat;
 set analytic_file;

 if OBESITYCAT not in (0,1) then OUT_EXCLUDE =1;
 else OUT_EXCLUDE =0;


 if OUT_EXCLUDE =1         then EXCLUDE =1;
 else if SVYEX_EXCLUDE =1  then EXCLUDE =1;
 else if BEC_MISSING =1    then EXCLUDE =1;
 else if SEC_MISSING =1    then EXCLUDE =1; else EXCLUDE =0;

 if BECPOPDENSL2 LE 4537.538988        then POPDENQUARTILE = 1; **PROC MEANS BELOW;
 else if BECPOPDENSL2 LE 6252.312257   then POPDENQUARTILE = 2;
 else if BECPOPDENSL2 LE 10025.433955  then POPDENQUARTILE = 3;
 else if BECPOPDENSL2 LE 30066.566425  then POPDENQUARTILE = 4;
 
 label   exclude = "Sample Size"
         POPDENQUARTILE = "Population Density Quartiles";

 format  exclude sample.
		 PopDenQuartile popden.;

 keep SALSVYID SALID1 SALID2 SVYYEAR ISO2 SVYMALE SVYAGE SVYAGECAT SVYWTKGSELF SVYHTCMSELF SVYBMISELF SVYBMICATSELF	
      SVYEDU SVYWTKG SVYHTCM SVYBMI SVYBMICAT OBESITYCAT OBESITY OVRWT_OBESITY_CAT BMICAT
      BECPOPDENSL2 BECPOPDENSL1AD /*TPOPDENSL2 TPOPDENSL1AD*/ popdenyr BECPOPDENSL2V3 BECPOPDENSL1ADV3 BECPOPDENSL2V1 BECADINTDENSL2 BECPCTURBANL1AD BECPTCHDENSL1AD BECAWMNNNGHL1AD BECPRSBRTL1AD	
      BECPRSSUBWAYL1AD CNSSE3_L2 BECMEDNDVINL2 POPDENQUARTILE EXCLUDE OUT_EXCLUDE SVYEX_EXCLUDE BEC_MISSING SEC_MISSING
	  BECPTCHDENSL1AD BECPCTURBANL1AD BECAWMNNNGHL1AD;


run;
data analysisDiabetes;
set out.analysisDiabetes;
where exclude = 0;
drop exclude;
run; *122,211 obs;
proc freq data = analysisDiabetes;
table iso2;
run;




***USED TO CREATE SAMPLE SIZE SPREADSHEET;
proc freq data = out.analysisDiabetes;
table iso2*OUT_EXCLUDE*BEC_MISSING*SVYEX_EXCLUDE/list missing;
where EXCLUDE =1;
*table iso2*OUT_EXCLUDE;
*table iso2*SVYEX_EXCLUDE;
*table iso2*BEC_MISSING;
*table iso2*SEC_MISSING;
run;
proc freq data = out.analysisObesity;
table iso2*OUT_EXCLUDE*BEC_MISSING*SVYEX_EXCLUDE/list missing;
where EXCLUDE =1;
*table iso2*exclude;
*table iso2*OUT_EXCLUDE;
*table iso2*SVYEX_EXCLUDE;
*table iso2*BEC_MISSING;
*table iso2*SEC_MISSING;
run;




*****
*CREATE FILES FOR ANALYSIS WITH EXCLUSIONS REMOVED (exclude = 0);
data analysisObesity;
set out.analysisObesity;
where exclude = 0;
drop exclude;
run; *93,280 obs;
proc freq data = analysisObesity;
table iso2;
run;
data analysisObesitycat;
set out.analysisObesitycat;
where exclude = 0;
drop exclude;
run;



*Clear formats;
proc datasets lib=work memtype=data nolist;
   modify analysisDiabetes; 
     attrib _all_ label=' '; 
     attrib _all_ format=;
     attrib _all_ informat=;
run;
proc datasets lib=work memtype=data nolist;
   modify analysisObesity; 
     attrib _all_ label=' '; 
     attrib _all_ format=;
     attrib _all_ informat=;
run;
proc datasets lib=work memtype=data nolist;
   modify analysisObesityCat; 
     attrib _all_ label=' '; 
     attrib _all_ format=;
     attrib _all_ informat=;
run;
data analysisDiabetes; 
 set analysisDiabetes; 
 format SALSVYID 13.0;
run;
data analysisObesity; 
 set analysisObesity; 
 format SALSVYID 13.0;
run;
data analysisObesityCat; 
 set analysisObesityCat; 
 format SALSVYID 13.0;
run;

**EXPORT CSV;
proc export data=analysisDiabetes
     outfile="....\Analysis\analysisDiabetes&date..csv"
     dbms=csv
     replace;
run;
proc export data=analysisObesitycat
     outfile="....\Analysis\analysisObesityCat&date..csv"
     dbms=csv
     replace;
run;
proc export data=analysisObesity
     outfile="....\Analysis\analysisObesity&date..csv"
     dbms=csv
     replace;
run;


/*
ODS listing close;
ODS tagsets.ExcelXP file = "....\BEC,SEC, Missing Distributions.xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Missing Distribution");
proc freq data =analytic_file; 
table Iso2*year*BECADINTDENSL2/  list missing nocum;
run;
proc freq data =analytic_file;
table iso2*year*BECADSTTDENSL2/  list missing nocum;
run;
proc freq data =analytic_file;
table iso2*year*BECMEDNDVINL2/  list missing nocum;
run;
proc freq data =analytic_file;
table iso2*year*CNSSE3_L2 / list missing nocum;
run;
ods tagsets.excelxp close;
ods listing;

*/

/*
ods pdf file="......\Plots\Population Density MS62 Obesity 01-05.pdf";
ods graphics on;
title "Population density V1 & V3 compared with population density that corresponds to survey year";
proc corr spearman ...data = analysisObesity;
var BECPOPDENSL2V1 BECPOPDENSL2;
run;.
proc corr spearman data = analysisObesity;
var BECPOPDENSL2V3 BECPOPDENSL2;
run;
ods graphics off;
ods pdf close;


ods pdf file="....\Plots\Population Density MS62 Diabetes 01-05.pdf";
ods graphics on;
title "Population density V1 & V3 compared with population density that corresponds to survey year";
proc corr spearman data = analysisDiabetes;
var BECPOPDENSL2V1 BECPOPDENSL2;
run;
proc corr spearman data = analysisDiabetes;
var BECPOPDENSL2V3 BECPOPDENSL2;
run;
ods graphics off;
ods pdf close;
*/


/*ods pdf file="....\Plots\Population Density MS62 Diabetes 12-8.pdf";
ods graphics on;
title "Old BEC population density compared with new population density that corresponds to survey year";
proc corr spearman data = analysisDiabetes;
var BECPOPDENSL2_old BECPOPDENSL2;
run;
proc corr data = analysisDiabetes;
var BECPOPDENSL2_old BECPOPDENSL2;
run;
proc corr data = analysisDiabetes;
var BECPOPDENSL2_new BECPOPDENSL2;
run;
ods graphics off;
ods pdf close;*/
