
/**********************************************************************
* Project           : MS62
*            		: Step 2-Descriptive tables for BMI
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
   class popdenquartile;
   where exclude =0;
   output out=means_&out.pop_&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;
run;

%mend meanstables;


%meanstables (analysisObesity, Obes, svyage);
%meanstables (analysisObesity, Obes, BECADINTDENSL2);
%meanstables (analysisObesity, Obes, BECMEDNDVINL2);
%meanstables (analysisObesity, Obes, BECPOPDENSL2);
%meanstables (analysisObesity, Obes, CNSSE3_L2);
%meanstables (analysisObesity, Obes, BECPCTURBANL1AD); 
%meanstables (analysisObesity, Obes, BECPTCHDENSL1AD); 
%meanstables (analysisObesity, Obes, OBESITY);
%meanstables (analysisObesity, Obes, BECAWMNNNGHL1AD);




*TABLE 1;
*COUNT PEOPLE BY CITY AND SUB-CITY;
*--------------------------------------;
proc freq data = out.analysisObesity noprint;
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
ods noproctitle;                                                                                                                        
                  
ODS tagsets.ExcelXP file = ".....\Output\Descriptive Statistics Obesity &date..xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sample Size");
title &Date;
title "Sample size by country";
proc tabulate data = out.analysisObesity;
class iso2 exclude ;
var Obesity;
table iso2*(exclude all) all*exclude, Obesity*n;
run;
title "Person count by city and sub-city";
proc print data = STAT_Total noobs label;
var Country TotalObs UniqueSALID_count1 median1 q1_1 q3_1 min1 max1 UniqueSALID_count2 median2 q1_2 q3_2 min2 max2;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="By Country");
title1 "Descriptive statistics by country";
proc freq data = out.analysisObesity;
table svymale*iso2/chisq norow nocum nopercent;
table svyedu*iso2/chisq norow nocum nopercent;
where exclude = 0;
run; 


title1;
proc print data = means_Obes_svyage noobs; title "Age"; run;
proc print data = means_Obes_Obesity  noobs; title "BMI"; run;
proc print data = means_Obes_BECADINTDENSL2 noobs; title "Intersection density" ;run;
proc print data = means_Obes_BECMEDNDVINL2  noobs; title "Median of Annual Maximum NDVI L2"; run;
proc print data = means_Obes_BECPOPDENSL2  noobs; title "Population density in built-up areas L2"; run; 
proc print data = means_Obes_CNSSE3_L2  noobs; title "Ana Ortigoza SE Factor 3 (education)"; run;
proc print data = means_Obes_becptchdensL1AD noobs; title "Patch Density L1AD"; run; 
proc print data = means_Obes_BECPCTURBANL1AD noobs; title "PCT Urban L1AD"; run; 
proc print data = means_Obes_BECAWMNNNGHL1AD  noobs; title "Urban Landscape, Isolation L1AD"; run;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 2");

title1 "Table 2 for manuscript";
title2 "Descriptive statistics by population density";
proc freq data = out.analysisDiabetes;
table ISO2*popdenyr*svyyear/list missing nocum nopercent;
run;

proc freq data = out.analysisObesity;
table svymale*popdenquartile/chisq norow nocum nopercent missing;
table svyedu*popdenquartile/chisq norow nocum nopercent missing;
where exclude = 0;
run;
title1;
title2;
proc sort data = out.analysisObesity; by descending Obesitycat popdenquartile; run;
proc freq data = out.analysisObesity order = data;
table BMIcat*popdenquartile/chisq norow nocum nopercent missing;
where exclude =0; 
run; 
proc print data = means_Obespop_svyage noobs; title "Age by population density quartiles"; run;
proc print data = means_Obespop_Obesity  noobs; title "BMI by population density quartiles"; run;
proc print data = means_Obespop_BECADINTDENSL2 noobs; title "Intersection density by population density quartiles" ;run;
proc print data = means_Obespop_BECMEDNDVINL2 noobs; title "Median of annual maximum NDVI by population density quartiles"; run;
proc print data = means_Obespop_BECPOPDENSL2  noobs; title "Built-up areas by population density quartiles";run; 
proc print data = means_Obespop_CNSSE3_L2  noobs; title "Ana Ortigoza SE Factor 3 (education) by population density quartiles";  run;
proc print data = means_Obespop_BECPCTURBANL1AD noobs; title "PCT urban by population density quartiles"; run; 
proc print data = means_Obespop_becptchdensl1ad noobs; title "Patch density by population density quartiles"; run; 
proc print data = means_Obespop_BECAWMNNNGHL1AD  noobs; title "Urban isolation by population density quartiles"; run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 3");
title "Correlation Matrix";
proc corr data = out.analysisObesity noprint outp = CORR;
var BECADINTDENSL2 BECMEDNDVINL2 BECPOPDENSL2 BECPTCHDENSL1AD BECAWMNNNGHL1AD BECPCTURBANL1AD  CNSSE3_L2 svyage Obesity;
where exclude = 0; 
run;
data CORRob;
 set CORR;
 where _type_ = 'CORR';
 drop _type_;
 rename _name_ = Variable;
run;
proc print data = CORRob noobs;
run;
ods tagsets.excelxp close;
ods listing;

Data foranalysis;
 set out.analysisObesity;
 where exclude = 0;
run;


/* Specify the ODS output path */

ods HTML path=".....\Plots" file = "loessObesity.html";
ods graphics on;


%macro loeesplot (var);
ods graphics on;
proc loess data=foranalysis PLOTS(MAXPOINTS=500000);
model Obesity = &var / smooth = 0.3;
title "Loess plots Obesity = &var ";
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
ods html close;*/
