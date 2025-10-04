/*STA 502: Statistical Programming
Fall Semester 2019 
Final SAS Project
Author: Kelvin Njuki
Due Date: 12/13/2019*/
/************************************************************************************************/
/************************************************************************************************/
					/*=====================*/
					/*"DATA CLEANING STEPS"*/
					/*=====================*/
/*Setting file path*/
%let project_path = M:\STA 502\Final SAS Project\Finals;
libname project "&project_path"; /*Creating SAS library folder for my dataset*/

/*Exploring number of missing values in every variable*/
proc means data=project.llcp2018 nmiss n; 
run;

/*Importing .csv file that contains state fips codes and their corresponding state names*/
PROC IMPORT OUT= WORK.STATEFIPSCODES 
            DATAFILE= "&project_path\StateFIPSicsprAB.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/*Merging brfss2018 and statefipscodes datasets by state fips codes*/
data brfss_statefips_merged;
	merge work.statefipscodes project.llcp2018;
	by _STATE;
run;

/* Input Variables of Interest
* STATE - STATE NAME
* ASTHMA3 - EVER TOLD HAD ASTHMA 
			(1-Yes, 2-No,7-Don't Know/Not Sure,9-Refused)
* CVDINFR4 - EVER DIAGNOSED WITH HEART ATTACK 
			(1-Yes,2-No,7-Don't Know/Not Sure,9-Refused)
* HAVARTH3 - TOLD HAVE ARTHRITIS 
			(1-Yes,2-No,7-Don't Know/Not Sure,9-Refused)
* CHCSCNCR - (EVER TOLD) YOU HAD SKIN CANCER? 
			(1-Yes,2-No,7-Don't Know/Not Sure,9-Refused)
* CHCOCNCR - (EVER TOLD) YOU HAD ANY OTHER TYPES OF CANCER 
			(1-Yes,2-No,7-Don't Know/Not Sure, 9-Refused)
* DIABETE3 - (EVER TOLD) YOU HAVE DIABETES 
			(1-Yes, 2-Yes(During pregnancy), 3-No,4-No(Pre-Diabetes),7-Don't Know/Not Sure, 9-Refused)
* _RFBING5 - BINGE DRINKING CALCULATED VARIABLE
* _SMOKER3 - COMPUTED SMOKING STATUS
* SMOKE100 - SMOKED AT LEAST 100 CIGARETTES IN THE ENTIRE LIFE 
			(1-Yes, 2-No,7-Don't Know/Not Sure,9-Refused)
* USENOW3 - USE OF SMOKELESS TOBACCO PRODUCTS LIKE CHEWING TOBACCO,SNUFF OR SNUS 
			(1-Every day,2-Some days,3-Not at all,7-Don’t know/Not sure,9-Refused)
* _AGEG5YR - REPORTED AGE IN FIVE-YEAR AGE CATEGORIES
				   1=(Age 18 to 24) 2=(Age 25 to 29) 3=(Age 30 to 34) 4=(Age 35 to 39) 5=(Age 40 to 44)
				   6=(Age 45 to 49) 7=(Age 50 to 54) 8=(Age 55 to 59) 9=(Age 60 to 64) 10=(Age 65 to 69)
				   11=(Age 70 to 74) 12=(Age 75 to 79) 13=(Age 80 or older) 14=Don’t know/Refused/ Missing;
*/

/*Subsetting brfss_statefips_merged data by selecting variables of interest */
proc sql; 
	create table work.brfss_clean as
	select STATE, _AGEG5YR, ASTHMA3, CVDINFR4, HAVARTH3, CHCSCNCR, CHCOCNCR, 
		   DIABETE3, _RFBING5,_SMOKER3, SMOKE100, USENOW3
	from work.brfss_statefips_merged;

/********************************************************************************************************************/
/********************************************************************************************************************/

			/*==================================================*/
			/*"SAS MACRO FUNCTIONS TO GENERATE PLOTS AND TABLES"*/
			/*==================================================*/
/*(1)SAS MACRO to test association between chronic diseases and health related risk behaviors in the entire United States*/
%macro risk_disease_ass(disease, risk_behavior);
	proc freq data = work.brfss_clean;
		title justify = center "Association between &disease and &risk_behavior, in United States";
		table &disease*&risk_behavior / nocum plots = mosaic chisq;
	run;
	title '';
%mend risk_disease_ass;

/*Calling MACRO to output results and save them in a word file document named ass_risk_vs_disease.doc
  Variables called are only for testing purpose, user can input variables of his/her interest*/
ods rtf file="&project_path/ass_risk_vs_disease.doc";
ods graphics on;
	%risk_disease_ass(disease = CHCOCNCR , risk_behavior = _RFBING5);
ods graphics off;
ods rtf close;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*(2)SAS MACRO to investigate association between different chronic diseases and age categories*/
%macro age_disease_ass(disease);
	proc freq data = work.brfss_clean;
		title justify = center "Association between &disease and age categories in United States";
		table &disease*_AGEG5YR / nocum plots = mosaic chisq;
	run;
%mend age_disease_ass;

/*Calling MACRO to output results and save them in a word file document named age_catgry_vs_disease.doc
  Variables called are only for testing purpose, user can input variables of his/her interest*/
ods rtf file="&project_path/age_catgry_vs_disease.doc";
ods graphics on;
	%age_disease_ass(disease=CHCOCNCR);
ods graphics off;
ods rtf close;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*(3)SAS MACRO to test ssociation between chronic diseases and health related risk behaviors in each state*/
%macro state_risk_disease_ass(state_data_name,state_name,disease,risk_behavior);
	proc sql;
	create table &state_data_name as 
	select * from work.brfss_clean
	where STATE="&state_name";
		proc freq data = &state_data_name;
			title"Association between &disease and &risk_behavior in &state_name State";
			table &disease*&risk_behavior / nocum plots = mosaic chisq;
	run;
	title'';
%mend state_risk_disease_ass;

/*Calling MACRO to output results and save them in a word file document named ass_state_risk_vs_disease.doc
  Variables called are only for testing purpose, user can input variables of his/her interest*/
ods rtf file="&project_path/ass_state_risk_vs_disease.doc";
ods graphics on;
	%state_risk_disease_ass(state_data_name = AlabamaState1,state_name = Alabama,
		disease = CHCOCNCR , risk_behavior = _RFBING5);
ods graphics off;
ods rtf close;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*(4)MACRO to test association between chronic disease and health risk behavior in a specific
  state for a given age category*/
%macro state_age_disease_risk_ass(state_subset_data,state_name,age_category, disease, risk_behavior);
	proc sql;
	create table &state_subset_data as 
	select * from work.brfss_clean
	where STATE="&state_name" and _AGEG5YR = &age_category;
		proc freq data = &state_subset_data;
			title justify=center "Association between &disease and &risk_behavior in &state_name State for 
								  age category &age_category";
			table &disease*&risk_behavior / nocum plots = mosaic chisq;
	run;
	title'';
%mend state_age_disease_risk_ass;

/*Calling MACRO to output results and save them in a word file document named ass_state_age_vs_disease.doc
  Variables called are only for testing purpose, user can input variables of his/her interest*/
ods rtf file="&project_path/ass_state_age_risk_vs_disease.doc";
ods graphics on;
	%state_age_disease_risk_ass(state_name = California,disease = CHCOCNCR , 
		risk_behavior = _RFBING5,state_subset_data = CaliforniaState,age_category = 10);
ods graphics off;
ods rtf close;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*(5)An overall SAS MACRO to combine above 4 MACROS into one where user can input state name, risk behavior, 
chronic disease and age category and MACRO will produce desired results*/
%macro association_report(state_data_name,state_subset_data, state_name, age_category, disease, risk_behavior);
	data overall_ass_report;
	set work.brfss_clean;
		%risk_disease_ass(&disease, &risk_behavior);
		%age_disease_ass(&disease);
		%state_risk_disease_ass(&state_data_name,&state_name,&disease,&risk_behavior);
		%state_age_disease_risk_ass(&state_subset_data,&state_name,&age_category, &disease, &risk_behavior);
	run;
%mend association_report;

/*Testing the MACRO with Alabama state using age category 3(Age 30 to 34) to find out 
  association between cancer and binge drinking*/
ods rtf file="&project_path/overall_ass_report.doc";
ods graphics on;
	%association_report(state_data_name = Alabama, state_subset_data = AlabamaState, 
							state_name = Alabama, age_category = 3, disease = CHCOCNCR , risk_behavior = _RFBING5);
ods graphics off;
ods rtf close;
/********************************************************************************************************************/
/********************************************************************************************************************/
					/*====================================*/
					/*"BOOTSTRAPPING AND PERMUTATION TEST"*/
					/*====================================*/
/*(6)SAS MACRO to perform non-parametric bootstrapping of brfss_clean data and output chi-square p-values for 
  association between chronic diseases and health related risk behaviors.
  The MACRO purposes to confirm whether results from MACRO (1) are really true*/

%macro boot_brfss_clean(reps,set_seed,input_data,output_data,disease,risk_behavior);
	proc surveyselect data=&input_data out=&output_data seed=&set_seed
	                  samprate=1 method=urs outhits rep=&reps;
	run;

	proc freq data = &output_data noprint;
		by replicate;
		table &disease*&risk_behavior / chisq;
		output out=chisq_pvalues pchi;
	run;

	data chisq_test_null_reject;
		set chisq_pvalues;
		reject = (P_PCHI<0.05);
	run;

	/*Calculating proportion of simulations in which the null hypothesis was rejected*/
	proc means data = chisq_test_null_reject mean;
		var reject;
	run;
%mend boot_brfss_clean;

/*Testing MACRO; User can supply variables of interest to the MACRO to get desired results*/
ods rtf file="&project_path/non_par_boot_chisq_test_report.doc";
ods graphics on;
	%boot_brfss_clean (reps=100, set_seed=1234567, input_data=brfss_clean, output_data=boot_brfss,
	disease = CHCOCNCR , risk_behavior = _RFBING5);
ods graphics off;
ods rtf close;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/*(7)SAS MACRO to perform permutation test for cases where expected counts were less than 5 making 
  chi-square an invalid test*/
%macro permutation_test(perm_data_name,perm_tall_data_name,state_data_name,state_name,age_category,disease, 
						risk_behavior, set_seed,reps);
	proc sql;
	create table &state_data_name as 
	select * from work.brfss_clean
	where STATE="&state_name";

	/*Creating a macro variable n_obs and assigning it number of observations in the dataset supplied*/
	data _null_;
	  set &state_data_name nobs=nobs;
	  call symput("n_obs", nobs);
	run;

	/*Permute disease supplied values*/
	data &perm_data_name;
		array x[&n_obs];
		array y[&n_obs];
		do i = 1 to &n_obs;
			set &state_data_name;
			x[i] = &disease;
			y[i] = &risk_behavior;
		end;
		seed = &set_seed;
		do perm = 1 to &reps;
			call ranperm(seed, of x[*]);
			output;
		end;
	run;

	/*Converting data from wide format to tall format*/
	data &perm_tall_data_name;
		set &perm_data_name;
		array x[&n_obs];
		array y[&n_obs];
		do i = 1 to &n_obs;
			&disease = x[i];
			&risk_behavior = y[i];
			output;
		end;
		keep STATE _AGEG5YR &disease &risk_behavior perm;
	run;

	/*Generating chi-square p-values*/
	proc freq data = &perm_tall_data_name noprint;
		by perm;
		table &disease*&risk_behavior / chisq;
		output out=chisq_perm_pvalues pchi;
	run;

	/*Saving chi-square p-values*/
	data chisq_test_rejection;
		set chisq_perm_pvalues;
		rejection = (P_PCHI<0.05);
	run;

	/*Calculating proportion of simulations in which the null hypothesis was rejected*/
	proc means data = chisq_test_rejection mean;
		var rejection;
	run;
%mend permutation_test;

/*Calling SAS MACRO. This is for demonstration purpose, user can supply his/her own variables of interest*/
ods rtf file="&project_path/perm_chisq_test_report.doc";
ods graphics on;
	%permutation_test(perm_data_name=perm_brfss_clean, perm_tall_data_name=perm_brfss_clean_tall, 
					  state_data_name = AlabamaState,state_name = Alabama,disease = CHCOCNCR , risk_behavior = _RFBING5,
					  set_seed=1234578,reps=1000);
ods graphics off;
ods rtf close;
/********************************************************************************************************************/
/********************************************************************************************************************/
