/**********************************************************************
* Project           : MS62
*            		: Step 2-Descriptive tables for Diabetes
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
    class diabetes;
    where exclude =0;
	output out=means_&out.1_&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;
 run;

 proc sort data = means_&out.1_&var;
 by descending diabetes;
 run;

 proc means data = out.&data maxdec=2 nway;
    var &var;
    where exclude =0;
	output out=means_&out.total_&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;
 run;

data all_&out._&var. ;
 retain  OutcomeDIABETES  n sd mean median min q1 q3 max;
 set means_&out.total_&var
     means_&out.1_&var;

	 if DIABETES = . then OutcomeDIABETES = "Overall diabetes sample";
	 else if DIABETES = 1 then OutcomeDIABETES = '(1) Yes';
	 else if DIABETES = 0 then OutcomeDIABETES = '(0) No';

	 label OutcomeDIABETES = "DIABETES";
	 drop DIABETES; 
run;

 proc means data = out.&data maxdec=2 nway;
   var &var;
   class popdenQuartile;
   where exclude =0;
   output out=means_&out.pop_&var (drop=_type_ _freq_) n=n stddev=sd mean=mean median=median min=min q1=q1 q3=q3 max=max;
run;


%mend meanstables;



%meanstables (analysisDiabetes, diab, svyage);
proc print data = all_diab_svyage label;
run;
options mprint = off;
%meanstables (analysisDiabetes, diab, BECADINTDENSL2);
%meanstables (analysisDiabetes, diab, BECMEDNDVINL2);
%meanstables (analysisDiabetes, diab, BECPOPDENSL2); 
%meanstables (analysisDiabetes, diab, CNSSE3_L2);
%meanstables (analysisDiabetes, diab, BECPTCHDENSL1AD); 
%meanstables (analysisDiabetes, diab, BECPCTURBANL1AD);
%meanstables (analysisDiabetes, diab, BECAWMNNNGHL1AD);



*TABLE 1;
*COUNT PEOPLE BY CITY AND SUB-CITY;
*--------------------------------------;
proc freq data = out.analysisDiabetes noprint;
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
proc sort data = STAT_Total;by country;run;
proc print data = STAT_Total;
var Country TotalObs UniqueSALID_count1 median1 q1_1 q3_1 min1 max1 UniqueSALID_count2 median2 q1_2 q3_2 min2 max2;
run;


*ANALYSIS TABLES;
ODS listing close;
ODS tagsets.ExcelXP file = ".....\Output\Descriptive Statistics Diabetes &date..xml" 
style=minimal
      options( embedded_titles='yes' embedded_footnotes='yes');

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Sample Size");
title "Sample size by country";
proc tabulate data = out.analysisDiabetes;
class iso2 exclude;
var diabetes;
table iso2*(exclude all) all*exclude, diabetes*n;
run;

title "Person count by city and sub-city";
proc print data = STAT_Total noobs label;
var Country TotalObs UniqueSALID_count1 median1 q1_1 q3_1 min1 max1 UniqueSALID_count2 median2 q1_2 q3_2 min2 max2;
run;

ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="By Country");
title1 "Descriptive statistics by country";
proc sort data = out.analysisDiabetes; by descending Diabetes; run; 
proc freq data = out.analysisDiabetes order=data;
table DIABETES*iso2/chisq norow nocum nopercent;
where exclude =0; 
run;
proc freq data = out.analysisDiabetes;
table svymale*iso2/chisq norow nocum nopercent;
table svyedu*iso2/chisq norow nocum nopercent;
where exclude =0; 
run; 
title1;
proc print data = means_diab_svyage noobs; title "Age"; run;
proc print data = means_diab_BECADINTDENSL2 noobs; title "Intersection density" ;run;
proc print data = means_diab_BECMEDNDVINL2  noobs; title "Median of Annual Maximum NDVI L2"; run;
proc print data = means_diab_BECPOPDENSL2  noobs; title "Population density in built-up areas L2"; run; 
proc print data = means_diab_CNSSE3_L2  noobs; title "Ana Ortigoza SE Factor 3 (education)"; run;
proc print data = means_diab_becptchdensl1ad noobs; title "Patch Density L1AD"; run; 
proc print data = means_diab_BECPCTURBANL1AD  noobs; title "PCT urban L1AD"; run;
proc print data = means_diab_BECAWMNNNGHL1AD  noobs; title "Urban Landscape, Isolation L1AD"; run;
title;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 1");
title1 "Table 1 for manuscript";
title2 "Descriptive statistics by outcome";
proc sort data = out.analysisDiabetes; by descending Diabetes svyagecat svymale svyedu; run; 
proc freq data = out.analysisDiabetes order = data;
table svymale*diabetes/chisq norow nocum nopercent;
table svyedu*diabetes/chisq norow nocum nopercent;
where exclude =0; 
run; 
title1;
title2;
proc print data = all_diab_svyage noobs; title "Age"; run;
proc print data = all_diab_BECADINTDENSL2  noobs; title "Intersection density L2"; run;
title "Median of annual maximum NDVI L2"; 
proc print data = all_diab_BECMEDNDVINL2  noobs; run; 
title "Population density in built-up areas L2";
proc print data = all_diab_BECPOPDENSL2  noobs; run; 
title "Ana Ortigoza SE Factor 3 (education) L2"; 
proc print data = all_diab_CNSSE3_L2  noobs; run;
title "Patch density L1AD";
proc print data = all_diab_becptchdensl1ad noobs; run;  
title "PCT urban L1AD";
proc print data = all_diab_BECPCTURBANL1AD noobs; run; 
title "Urban Landscape, Isolation L1AD";
proc print data = all_diab_BECAWMNNNGHL1AD noobs; run;
title;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 2");
title1 "Table 2 for manuscript";
title2 "Descriptive statistics by population density";
proc freq data = out.analysisDiabetes;
table ISO2*popdenyr*svyyear/list missing nocum nopercent nofreq;
run;
proc freq data = out.analysisDiabetes;
table svymale*popdenquartile/chisq norow nocum nopercent missing;
table svyedu*popdenquartile/chisq norow nocum nopercent missing;
where exclude =0 ; 
run;
title1;
title2;
proc sort data = out.analysisDiabetes; by descending diabetes popdenquartile; run;
proc freq data = out.analysisDiabetes order=data;
table diabetes*popdenquartile/chisq norow nocum nopercent missing;
where exclude =0; 
run; 
proc print data = means_diabpop_svyage noobs; title "Age by population density quartiles"; run;
proc print data = means_diabpop_BECADINTDENSL2 noobs; title "Intersection density by population density quartiles" ;run;
proc print data = means_diabpop_BECMEDNDVINL2 noobs; title "Median of annual maximum NDVI by population density quartiles"; run;
proc print data = means_diabpop_BECPOPDENSL2  noobs; title "Population density in built-up areas by population density quartiles";run; 
proc print data = means_diabpop_CNSSE3_L2  noobs; title "Ana Ortigoza SE Factor 3 (education) by population density quartiles";  run;
proc print data = means_diabpop_BECPCTURBANL1AD noobs; title "PCT urban by population density quartiles"; run; 
proc print data = means_diabpop_becptchdensl1ad noobs; title "Patch density by population density quartiles"; run; 
proc print data = means_diabpop_BECAWMNNNGHL1AD noobs; title "Urban isolation by population density quartiles"; run; 
title;


ods tagsets.ExcelXP options(sheet_interval ="none" sheet_name="Table 3");
title "Correlation";
proc corr data = out.analysisDiabetes noprint outp = CORR;
var BECADINTDENSL2 BECMEDNDVINL2 BECPOPDENSL2 BECPTCHDENSL1AD BECAWMNNNGHL1AD BECPCTURBANL1AD CNSSE3_L2 svyage;
where exclude = 0; 
run;
data CORRDIAB;
 set CORR;
 where _type_ = 'CORR';
 drop _type_;
 rename _name_ = Variable;
run;
proc print data = CORRDIAB noobs;
run;
ods tagsets.excelxp close;
ods listing;


/*
 if BECPOPDENSL2 gt 150000 then flag = 1;
 else flag = 0;


 threesd = 9823.768058+ (8017.917391*3); *24,051;
 foursd = 9823.768058+ (8017.917391*4); *32,068; 

 if BECPOPDENSL2 le threesd then flagthree = 0;
 if BECPOPDENSL2 gt threesd then flagthree = 1;

 if BECPOPDENSL2 le foursd then flagfour = 0;
 if BECPOPDENSL2 gt foursd then flagfour = 1;

run;
proc freq data = foranalysis;
table flag*iso2 flagthree flagfour;
run;
proc means data = foranalysis min q1 mean median q3 std max maxdec=6;
var BECPOPDENSL2 ;
run;
*/



Data foranalysis;
 set out.analysisDiabetes;
 where exclude = 0;
run;


/* Specify the ODS output path */

ods html path=".....\Plots" file = "loessDiabetes.html";
ods graphics on;


%macro loeesplot (var);
ods graphics on;
proc loess data=foranalysis PLOTS(MAXPOINTS=500000);
model diabetes = &var / smooth = 0.3;
title "Loess plots Diabetes = &var ";
run;
%mend;


%loeesplot (SVYAGE);
%loeesplot (BECADINTDENSL2);
%loeesplot (BECMEDNDVINL2);
%loeesplot (BECPOPDENSL2);
%loeesplot (CNSSE3_L2);
%loeesplot (BECPTCHDENSL1AD); 
%loeesplot (BECAWMNNNGHL1AD);

ods graphics off;
ods html close;

