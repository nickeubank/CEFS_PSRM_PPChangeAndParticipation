

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
    zipuse 20_intermediate_files/60_voter_panel_long_w_analysisvars_no_movers_dta.zip
}
else {
    use 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_no_movers.dta, clear
}









			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* create a county variable that will merge with coverage data
*-------------------------------------------------------------------------------


* use value labels for county to generate strings
*------------------------------------------------

// decode county, gen(county_string)
gen county_string = county
label var county_string "county variable for merging with coverage"



* remove the word "County" from the names
*----------------------------------------

	// since that end string won't merge with the coverage file county variable

replace county_string = regexr(county_string, "( [cC]ounty)$", "")
replace county_string = regexr(county_string, "( [cC]ity)$", "")




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* merge coverage data
*-------------------------------------------------------------------------------


* merge
*------

merge m:1	county_string using "20_intermediate_files/county_coverage.dta"


	* assert
	*-------

	assert _merge != 2			// no county strings from the coverage file should go un-matched






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* drop non-NC counties
*-------------------------------------------------------------------------------

	// drop individuals in any counties that are not in north carolina

* drop
*-----

drop if _merge == 1			// in voter file but not in list of NC counties by coverage status



* drop merge variable
*--------------------

drop _merge


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* there should be 100 counties total
*-------------------------------------------------------------------------------

* assert
*-------

egen group_ct = group(county_string)
sum group_ct
assert `r(max)' == 100
drop group_ct






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* save the data
*-------------------------------------------------------------------------------


* save
*-----


if "$sample_size" == "full" {
    zipsave 20_intermediate_files/70_voter_panel_long_w_analysisvars_merged_coverage_no_movers_dta.zip, replace
}
else {
    save 20_intermediate_files/70_voter_panel_10pctsample_long_w_analysisvars_merged_coverage_no_movers.dta, replace
}






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**

				** end of 10_merge_vra_coverage.do file **
