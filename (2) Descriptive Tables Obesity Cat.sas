/**********************************************************************
* Project           : MS62
*            		: Step 2-Descriptive tables for Obesity
* Author            : CK
* Date created      : 03/11/2020
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

%macro meanstables (data, out, var);
proc means data=out.&data maxdec=2 nway;
	where exclude = 0;
	var &var;
	class iso2;
	output out=means_&out._&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;  
run;

proc means data = out.&data maxdec=2 nway;
    var &var;
    class ObesityCat;
    where exclude =0;
	output out=means_&out.1_&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;
 run;

 proc sort data = means_&out.1_&var;
 by descending ObesityCat;
 run;

 proc means data = out.&data maxdec=2 nway;
    var &var;
    where exclude =0;
	output out=means_&out.tot_&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;
 run;

data all_&out._&var. ;
retain  OutcomeObesity  n sd mean median min q1 q3 max;
 set means_&out.tot_&var
     means_&out.1_&var;

	 	  If OBESITYCAT = . then OutcomeObesity = "Overall obesity sample";
	 else if OBESITYCAT = 1 then OutcomeObesity = '(1) Yes';
	 else if OBESITYCAT = 0 then OutcomeObesity = '(0) No';

	 label OutcomeObesity = "Obesity";
	       Obesity = "BMI";

	 drop OBESITYCAT;
run;

 proc means data = out.&data maxdec=2 nway;
   var &var;
   class popdenquartile;
   where exclude =0;
   output out=means_&out.pop_&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;
run;

%mend meanstables;

%meanstables (analysisObesitycat, Obescat, svyage);
proc print data = all_Obescat_svyage label;
run;
%meanstables (analysisObesitycat, Obescat, BECADINTDENSL2);
%meanstables (analysisObesitycat, Obescat, BECMEDNDVINL2);
%meanstables (analysisObesitycat, Obescat, BECPOPDENSL2); 
%meanstables (analysisObesitycat, Obescat, CNSSE3_L2);
%meanstables (analysisObesitycat, Obescat, BECPCTURBANL1AD); 
%meanstables (analysisObesitycat, Obescat, BECPTCHDENSL1AD);
%meanstables (analysisObesityCat, ObesCat, OBESITY);
%meanstables (analysisObesityCat, ObesCat, BECAWMNNNGHL1AD);



*TABLE 1;
*COUNT PEOPLE BY CITY AND SUB-CITY;
*--------------------------------------;

proc freq data = out.analysisObesityCat noprint;
table iso2*salid1/out = count1;
table iso2*salid2/out = count2;
where exclude =0;
run;
proc print data = count1(obs = 10); run;
proc print data = count2(obs = 10); run;

*STATISTICS ABOUT COUNTS;
proc means data = count1  maxdec = 2;
var count;
class iso2;
output out = SALID1STAT (drop=_type_ _freq_) n=UniqueSALID_count1 min=min1 q1=q1_1 median=median1 q3=q3_1 max=max1 sum=TotalObs;
run;
proc means data = count2 noprint maxdec = 2;
var count;
class iso2;
output out = SALID2STAT (drop=_type_ _freq_) n=UniqueSALID_count2 min=min2 q1=q1_2 median=median2 q3=q3_2 max=max2 sum=TotalObs;
run;
DATA STAT_Total;
 merge SALID1STAT (in =a)
       SALID2STAT (in = b);
 by iso2;
 length country $8.;

 if ISO2 = "" then Country = "Total";
 else country = iso2;

 drop iso2;

 label 
       UniqueSALID_count1 ="Number of units L1"
       UniqueSALID_count2 ="Number of units L2"
       min1 = "Min number participants L1"
       min2 ="Min number participants L2"
       q1_1 ="25th Percentile L1"
       q1_2 ="25th Percentile L2"
       median1 ="Median number participants per L1 unit"
       median2 ="Median number participants per L2 unit"
       q3_1 ="75th Percentile L1"
       q3_2 ="75th Percentile L2"
       max1 ="Max number participants L1"
       max2 ="Max number participants L2"
       TotalObs ="Number of obs";

run;
proc sort data = STAT_Total;
by country;
run;
proc print data = STAT_Total;
var Country TotalObs UniqueSALID_count1 median1 q1_1 q3_1 min1 max1 UniqueSALID_count2 median2 q1_2 q3_2 min2 max2;
run;


*ANALYSIS TABLES;


ODS listing close;
ODS tagsets.ExcelXP file = ".....\Output\Descriptive Statistics Obesity Categorical &date..xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sample Size");
title &Date;
title "Sample size by country";
proc tabulate data = out.analysisObesityCat;
class iso2 exclude ;
var ObesityCat;
table iso2*(exclude all) all*exclude, ObesityCat*n;
run;

title "Person count by city and sub-city";
proc print data = STAT_Total noobs label;
var Country TotalObs UniqueSALID_count1 median1 q1_1 q3_1 min1 max1 UniqueSALID_count2 median2 q1_2 q3_2 min2 max2;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="By Country");
title1 "Descriptive statistics by country";
proc sort data = out.analysisObesityCat; by descending obesitycat iso2; run; 
proc freq data = out.analysisObesityCat order=data;
table obesitycat*iso2/chisq norow nocum nopercent;
where exclude =0; 
run;

proc freq data = out.analysisObesityCat;
table svymale*iso2/chisq norow nocum nopercent;
table svyedu*iso2/chisq norow nocum nopercent;
where exclude =0; 
run; 
title1; 
proc print data = means_ObesCat_svyage noobs; title "Age"; run;
proc print data = means_ObesCat_OBESITY noobs; title "BMI"; run;
proc print data = means_ObesCat_BECADINTDENSL2 noobs; title "Intersection density" ;run;
proc print data = means_ObesCat_BECMEDNDVINL2  noobs; title "Median of Annual Maximum NDVI L2"; run;
proc print data = means_ObesCat_BECPOPDENSL2  noobs; title "Population density in built-up areas L2"; run; 
proc print data = means_ObesCat_CNSSE3_L2  noobs; title "Ana Ortigoza SE Factor 3 (education)"; run;
proc print data = means_ObesCat_becptchdensl1ad noobs; title "Patch Density L1AD"; run; 
proc print data = means_ObesCat_BECPCTURBANL1AD noobs; title "PCT Urban L1AD"; run; 
proc print data = means_ObesCat_BECAWMNNNGHL1AD  noobs; title "Urban Landscape, Isolation L1AD"; run;
title;



ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 1");
title1 "Table 1 for manuscript";
title2 "Descriptive statistics by outcome";
proc sort data = out.analysisObesityCat; by descending ObesityCat svymale svyedu; run; 
proc freq data = out.analysisObesityCat order = data;
table svymale*ObesityCat/chisq norow nocum nopercent;
table svyedu*ObesityCat/chisq norow nocum nopercent;
where exclude =0; 
run; 
proc sort data = out.analysisObesityCat; by descending obesityCat bmicat; run; 
proc freq data = out.analysisObesityCat order = data;
table bmiCat*ObesityCat /chisq norow nocum nopercent;
where exclude =0; 
run; 
title1;
title2;
title "Age";
proc print data = all_Obescat_svyage noobs; title "Age"; run;
title "BMI";
proc print data = all_Obescat_OBESITY noobs; run;
title "Intersection density L2";
proc print data = all_Obescat_BECADINTDENSL2 noobs;run;
title "Median of annual maximum NDVI "; 
proc print data = all_Obescat_BECMEDNDVINL2  noobs; run; 
title "Population density in built-up areas L2";
proc print data = all_Obescat_BECPOPDENSL2  noobs; run;
title "Ana Ortigoza SE Factor 3 (education)"; 
proc print data = all_Obescat_CNSSE3_L2  noobs; run;
title "Patch density L1AD";
proc print data = all_Obescat_becptchdensl1ad noobs; run; 
title "PCT urban L1AD";
proc print data = all_Obescat_BECPCTURBANL1AD noobs; run; 
title "Urban Landscape, Isolation L1AD";
proc print data = all_ObesCat_BECAWMNNNGHL1AD  noobs; run;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 2");
title1 "Table 2 for manuscript";
title2 "Descriptive statistics by population density";
proc freq data = out.analysisDiabetes;
table ISO2*popdenyr*svyyear/list missing nocum nopercent;
run;

proc freq data = out.analysisObesityCat;
table svymale*popdenquartile/chisq norow nocum nopercent;
table svyedu*popdenquartile/chisq norow nocum nopercent;
where exclude =0; 
run; 

proc sort data = out.analysisObesityCat; by descending obesityCat popdenquartile; run;
proc freq data = out.analysisObesityCat order=data;
table obesityCat*popdenquartile/chisq norow nocum nopercent missing;
where exclude =0; 
run;
proc sort data = out.analysisObesityCat; by descending bmicat popdenquartile; run;
proc freq data = out.analysisObesityCat order=data;
table bmicat*popdenquartile/chisq norow nocum nopercent missing;
where exclude =0; 
run; 

proc print data = means_obescatpop_svyage noobs; title "Age by population density quartiles"; run;
proc print data = means_obescatpop_OBESITY noobs; title   "BMI by population density quartiles"; run;
proc print data = means_obescatpop_BECADINTDENSL2 noobs; title "Intersection density by population density quartiles" ;run;
proc print data = means_obescatpop_BECMEDNDVINL2 noobs; title "Median of annual maximum NDVI by population density quartiles"; run;
proc print data = means_obescatpop_BECPOPDENSL2  noobs; title "Built-up areas by population density quartiles";run; 
proc print data = means_obescatpop_CNSSE3_L2  noobs; title "Ana Ortigoza SE Factor 3 (education) by population density qurtiles";  run;
proc print data = means_obescatpop_BECPCTURBANL1AD noobs; title "PCT urban by population density quartiles"; run; 
proc print data = means_obescatpop_becptchdensl1ad noobs; title "Patch density by population density quartiles"; run; 
proc print data = means_Obescatpop_BECAWMNNNGHL1AD  noobs; title "Urban Landscape Isolation by population density quartiles"; run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 3");
title "Correlation";
proc corr data = out.analysisObesityCat noprint outp = CORR;
var BECADINTDENSL2 BECMEDNDVINL2 BECPOPDENSL2 BECPTCHDENSL1AD BECAWMNNNGHL1AD BECPCTURBANL1AD  CNSSE3_L2 svyage;
where exclude = 0; 
run;
data CORRObCat;
 set CORR;
 where _type_ = 'CORR';
 drop _type_;
 rename _name_ = Variable;
run;
proc print data = CORRObCat noobs;
run;
ods tagsets.excelxp close;
ods listing;


Data foranalysis;
 set out.analysisObesityCat;
 where exclude = 0;


 /*if BECPOPDENSL2 gt 150000 then flag = 1;
 else flag = 0;

 threesd = 9823.768058+ (8161.645561*3); *24,483;
 foursd = 9823.768058+ (8161.645561*4); *32,644; 

 if BECPOPDENSL2 le threesd then flagthree = 0;
 if BECPOPDENSL2 gt threesd then flagthree = 1;

 if BECPOPDENSL2 le foursd then flagfour = 0;
 if BECPOPDENSL2 gt foursd then flagfour = 1;*/

run;
proc means data = foranalysis min q1 mean median q3 std max maxdec=6;
var BECPOPDENSL2 ;
class iso2;
run;
/*proc freq data = foranalysis;
table flag flagthree flagfour;
run;
*/

/* Specify the ODS output path */

ods html path=".....\Plots" file="loessObesityCat.html";
ods graphics on;


%macro loeesplot (var);
ods graphics on;
proc loess data=foranalysis PLOTS(MAXPOINTS=500000);
model ObesityCat = &var / smooth = 0.3;
title "Loess plots ObesityCat = &var ";
run;
%mend;

%loeesplot (SVYAGE);
%loeesplot (BECADINTDENSL2);
%loeesplot (BECMEDNDVINL2);
%loeesplot (BECPOPDENSL2); 
%loeesplot (CNSSE3_L2);
%loeesplot (BECPTCHDENSL1AD); 
%loeesplot (BECPCTURBANL1AD);
%loeesplot (BECAWMNNNGHL1AD);

ods graphics off;
ods html close;



