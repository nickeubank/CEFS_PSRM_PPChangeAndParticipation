


	************************************************************************
	**
	**
	**		PROJECT AUTHORS:	CLINTON, EUBANK, FRESH & SHEPHERD
	**		DO FILE AUTHOR:		FRESH
	**		DATE BEGUN: 		February 18, 2018
	**
	**		PROJECT: 			NC Electioneering
	**		DETAILS:
	**
	**		UPDATES:
	**
	**
	**		VERSION: 			Adriane coded/ran this w/ Stata Version 14.2 IC
	**
	**
	*************************************************************************








			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------


* set directory
*--------------

cd "${nc_electioneering}"



* preliminaries
*--------------

clear
set more off



* use data
*---------

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/70_voter_panel_long_w_analysisvars_merged_coverage_no_movers_dta.zip, clear
}
else {
    use 20_intermediate_files/70_voter_panel_10pctsample_long_w_analysisvars_merged_coverage_no_movers.dta, clear
}







			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* generate average outcomes for each of our main outcome variables
*-------------------------------------------------------------------------------


* averages for the outcomes
*--------------------------

local outcomes = "pp_minutes_driving pp_has_changed voted_elecday"


foreach out in `outcomes' {

	bysort county year: egen test1 = mean(`out')
	bysort county year: egen `out'_avg = max(test1)

	label var `out'_avg "county average of `out'"

	drop test1

}




* averages of the outcomes by coverage status
*--------------------------------------------

forvalues covered = 0/1 {

	if `covered' == 1 {

		local cov_end_string = "cov"

	}
	else if `covered' == 0 {

		local cov_end_string = "unc"

	}

	bysort county year: egen test1 = mean(pp_minutes_driving) 		if covered == `covered'
	bysort county year: egen pp_minutes_driving_avg_`cov_end_string' = max(test1)
	label var pp_minutes_driving_avg_`cov_end_string' "county average pp min driving for `cov_end_string' counties"


	bysort county year: egen test2 = mean(pp_has_changed) 			if covered == `covered'
	bysort county year: egen pp_has_changed_avg_`cov_end_string' = max(test2)
	label var pp_has_changed_avg_`cov_end_string' "county average of pp has changed for `cov_end_string' counties"

	bysort county year: egen test3 = mean(voted_elecday) 			if covered == `covered'
	bysort county year: egen voted_elecday_avg_`cov_end_string' = max(test3)
	label var voted_elecday_avg_`cov_end_string' "countyaverage of voted on elec day for `cov_end_string' counties"

	drop test1 test2 test3

}


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* post-shelby variable
*-------------------------------------------------------------------------------


* post variable
*--------------

gen post_shelby = .
replace post_shelby = 1 	if year > 2013
replace post_shelby = 0		if post_shelby == .

label var post_shelby "=1 for years post-2013 and the shelby decision; =0 otherwise"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* interaction between post and coverage variable
*-------------------------------------------------------------------------------


* post by coverage interaction
*-----------------------------

gen post_x_covered = post_shelby * covered
label var post_x_covered "post-shelby interacted with covered"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* numeric county group variable
*-------------------------------------------------------------------------------


* county group
*-------------

egen county_id = group(county_string)
order county_id, after(county_string)
label var county_id "numeric county identifier"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* tags
*-------------------------------------------------------------------------------


* tag county and year
*--------------------

egen tag_ct_yr = tag(county year)
label var tag_ct_yr "=1 for one obsv of a county-year pair"



* tag year
*---------

egen tag_yr	= tag(year)
label var tag_yr "=1 for one obsv of a year"



* tag county
*-----------

egen tag_ct = tag(county)
label var tag_ct "=1 for one obsv of a county"



* tag covered year
*----------------

egen tag_cov_yr = tag(covered year)
label var tag_cov_yr "=1 for 1 obsv of a coverage-year pair"






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* save the data
*-------------------------------------------------------------------------------


* save
*-----

if "$sample_size" == "full" {
    zipsave 20_intermediate_files/80_voter_panel_long_w_analysisvars_newdindvars_no_movers_dta.zip, replace
}
else {
    save 20_intermediate_files/80_voter_panel_10pctsample_long_w_analysisvars_newdindvars_no_movers.dta, replace
}





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**

				** end 15_new_vars_for_analysis.do file **
