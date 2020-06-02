

    ************************************************************************
    **
    **
    **        PROJECT AUTHORS:    CLINTON, EUBANK, FRESH & SHEPHERD
    **        DO FILE AUTHOR:        EUBANK
    **        DATE BEGUN:         April 23, 2018
    **
    **        PROJECT:            NC Electioneering
    **        DETAILS:
    **
    **        UPDATES:  		  Paper Table Outputs.
    **
    **
    **        VERSION:             Stata 14
    **
    **
    *************************************************************************





*-------------------------------------------------------------------------------
* THIS FILE RELIES ON GLOBAL VARIABLES AND DATA CREATED IN
*
* 40_paper_analysis_prep.do
*
* RUN THAT FILE FIRST AND IN SAME SESSION AS CODE IN THIS FILE
*-------------------------------------------------------------------------------


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------


clear
set more off




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* define our file output directory
*-------------------------------------------------------------------------------


* define output directory
*------------------------

global output "${nc_electioneering}/50_results_$sample_size"




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* define globals for outputting individual values
*-------------------------------------------------------------------------------


* define close, open and write
*-----------------------------

global closef 	= "capture file close myfile"
global openf 	= "file open myfile using"
global writef 	= "file write myfile"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* read in data
*-------------------------------------------------------------------------------


* data
*-----

cd $nc_electioneering

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/90_voter_panel_wallanalysisvars_no_movers_dta.zip, clear
}
else {
    use 20_intermediate_files/90_voter_panel_10pctsample_wallanalysisvars_no_movers.dta, clear
}



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	Define the control variables used in the analyses
*-------------------------------------------------------------------------------

#delimit ;

* panel controls;
*---------------;



global controls_panel = "black_x_year hispanic_x_year unknown_x_year other_x_year
						native_am_x_year asian_x_year multi_race_x_year "
						;

global interaction_fe = "c_*"  ;



* individual controls;
*--------------------;

global controls_crosssection = 	"voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag
								age age2 female black hispanic unknown other native_am asian
								multi_race census_hh_med_income party_rep party_una party_lib"
						;


#delimit cr



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* define global cleaner
*-------------------------------------------------------------------------------

	// makes sure old dvs and ivs don't impact future regressions


* define global cleaner program
*------------------------------

capture program drop clean_globals

program clean_globals

    forvalues x = 1/7 {
        global dv`x' = ""
        global iv`x' = ""
        global cluster`x' = ""
        global year`x' = ""
    }
    end



* program to de-mean the outcome variables by individuals
*---------------------------------------------

	// to reflect the variation that we're leveraging in the analysis


capture program drop summary_stats
program define summary_stats
	local estimate `1'
	local dv `2'
	local fe `3'

	* Make sure works
	count if e(sample)
	assert e(N) == r(N)
	assert r(N) != 0

	* Add DV mean
	sum `dv' if e(sample)
	estadd scalar meandv = `r(mean)': `estimate'

	* Add within-individual SD
	bysort `fe': egen mean_dv = mean(`dv') if e(sample)
	gen demeaned_dv = `dv' - mean_dv if e(sample)
	sum demeaned_dv if e(sample)
	estadd scalar stddv = `r(sd)': `estimate'

	drop mean_dv demeaned_dv

end


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	TABLE 1: Sample Comparison
*
*		Description: Our sample of voters compared to the entire voter roll
*
*-------------------------------------------------------------------------------

* preserve
*---------

preserve



* load earlier dataset
*---------------------

cd $nc_electioneering

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/40_voter_panel_long_dta.zip, clear
}
else {
    use 20_intermediate_files/40_voter_panel_10pctsample_long.dta, clear
}



global output "${nc_electioneering}/50_results_$sample_size"



* voted variables
*----------------

gen voted_ANY 		= 1 			if ncsbe_voted != 7 & ncsbe_voted != .
replace voted_ANY 	= 0 			if voted_ANY != 1 & ncsbe_voted != .



* race variables
*---------------

gen white		= 1  if race == 0
gen black		= 1  if race == 1
gen unknown		= 1  if race == 2
gen other		= 1  if race == 3
gen native_am	= 1  if race == 4
gen asian		= 1  if race == 5
gen multi_race	= 1  if race == 6

local races = "white unknown other native_am asian multi_race"

foreach race of local races {

		replace `race' = 0 	if `race' == .

}



* party variables
*----------------

gen party_dem = 1 if party == 0
gen party_rep = 1 if party == 1
gen party_una = 1 if party == 2
gen party_lib = 1 if party == 3

local parties = "dem rep una lib"

foreach party of local parties {

		replace party_`party' = 0 	if party_`party' == .

}



* re-code non-white
*------------------

gen nwhite = 1 			if white == 0
replace nwhite = 1		if white == 1 & hispanic == 0
replace nwhite = 0 		if nwhite == .



* tag eligible voters
*--------------------

gen temp_can_vote = 1 if (voter_status == 0 | voter_status == 2 | voter_status == 4)
replace temp_can_vote = 0 	if temp_can_vote == .



* remove voters who were never eligible to vote
*----------------------------------------------

bysort ncid: egen temp_years_can_vote = sum(temp_can_vote)
drop if temp_years_can_vote == 0



* tag individuals
*----------------

egen tag_voter = tag(ncid)



* movers
*-------

tsset voter_index election_index
sort  voter_index election_index

gen voter_moved = (census_block != L.census_block) 	if census_block != . & L.census_block != .
label var voter_moved "voter moved since last presidential election"

bysort ncid: egen ever_moved = max(voter_moved)
sum ever_moved, meanonly
assert r(mean) < 0.31



* variables for the table
*------------------------

local variables = "voted_ANY age female white nwhite party_rep party_dem party_una ever_moved"


foreach v of local variables {

	cd "${output}"


	sum `v' if year > 2008

	// mean
	${closef}
	${openf} 	"`v'_mean_presamp.tex"	, write replace
	${writef} 	%7.2f (`r(mean)')
	${closef}

    ${closef}
	${openf} 	"`v'_N_presamp.tex"	, write replace
	${writef} 	%14.0fc (`r(N)')
	${closef}


}




* restore
*--------

restore







			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	TABLE 2/3 combined: Panel PP Change
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling place has changed
*		Sample: 		Panel
*		Interactions: 	None
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals


global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv2					= "closer_5up"
global iv3					= "further_5up"
global iv1					= "pp_has_changed"

global cluster1				= "precinct_group"
global absorb				= "ncid"


* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_combined"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_PanelOnly_AverageAndCloserFurther.do"


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE 2.5: Testing for composition shift
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling place has changed * Party
*		Sample: 		Panel & Cross-Sections
*		Interactions: 	Party
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_ANY"

global number_of_outcomes	= 1

global iv1					= "pp_has_changed pp_has_changed_x_party_rep pp_has_changed_x_party_una"

global controls_composition = "party_rep party_una"

#delimit ;
global controls_crosssection_comp = 	"voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag
								age age2 female black hispanic unknown other native_am asian
								multi_race census_hh_med_income party_rep party_una "
						;
#delimit cr

global cluster1				= "precinct_group"
global cluster2				= "county_fips"
global absorb				= "ncid"


global year1				= "year == 2012"
global year2				= "year == 2016"



* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_substitution_v_composition"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelandCrossSection_Composition.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	TABLE 4:	Descriptive statistics of polling place impact
*
*		Description:	Who is impacted by demographic characteristics
*-------------------------------------------------------------------------------


* keep
*-----

preserve



* sample size
*------------

	// check if working with the 10% sample

sum voter_index

if "$sample_size" == "10percent" {
    count
    assert `r(N)' < 1000000
}
else {
    count
    assert `r(N)' > 1000000
}





* statistics
*-----------

cd "${output}"
local years = "2012 2016"

capture drop tag_voter
capture drop tag_voter_yr
capture drop total_voter

egen tag_voter = tag(ncid year)
bysort year: egen total_voter = total(tag_voter)

sum total_voter if year == 2012
local total_voter_2012 = `r(mean)'

if "$sample_size" == "10percent" {
    local total_voter_2012 = `total_voter_2012' * 10
}

sum total_voter if year == 2016
local total_voter_2016 = `r(mean)'

if "$sample_size" == "10percent" {
    local total_voter_2016 = `total_voter_2016' * 10
}


foreach yr of local years {

	capture drop pp_has_changed_num_`yr'

    * Absolute num
	count if year == `yr' & pp_has_changed == 1
    local absolute_num = r(N)

    * Proportion
	sum  pp_has_changed if year == `yr'
    local proportion_changed = r(mean)


    if "$sample_size" == "10percent" {
        local stat = `absolute_num' * 10
    }

	${closef}
	${openf} 	"pp_`yr'.tex"	, write replace
	${writef} 	%12.0fc (`absolute_num')
	${closef}

	${closef}
	${openf} 	"pp_`yr'_perc.tex"	, write replace
	${writef} 	%7.2fc (`proportion_changed')*100
	${closef}


	forvalues race = 0/1 {

        * Absolute num
        count if year == `yr' & pp_has_changed == 1 & race == `race'
        local absolute_num = r(N)

        * Proportion
        sum  pp_has_changed if year == `yr' & race == `race'
        local proportion_changed = r(mean)


        if "$sample_size" == "10percent" {
            local stat = `absolute_num' * 10
        }

		${closef}
		${openf} 	"pp_`yr'_race_`race'.tex"	, write replace
		${writef} 	%12.0fc (`absolute_num')
		${closef}

		${closef}
		${openf} 	"pp_`yr'_race_`race'_perc.tex"	, write replace
		${writef} 	%7.2fc (`proportion_changed')*100
		${closef}

	}


	forvalues party = 0(1)2 {

        * Absolute num
        count if year == `yr' & pp_has_changed == 1 & party == `party'
        local absolute_num = r(N)

        * Proportion
        sum  pp_has_changed if year == `yr' & party == `party'
        local proportion_changed = r(mean)

        local stat = r(mean)
        if "$sample_size" == "10percent" {
            local stat = `absolute_num' * 10
        }

		${closef}
		${openf} 	"pp_`yr'_party_`party'.tex"	, write replace
		${writef} 	%12.0fc (`absolute_num')
		${closef}

		${closef}
		${openf} 	"pp_`yr'_party_`party'_perc.tex"	, write replace
		${writef} 	%7.2fc (`proportion_changed')*100
		${closef}

	}



}



* restore
*--------

restore




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	TABLE 5: Cross-Sectional Partisan Polling Place Effects
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling Place has Changed
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	None
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed"

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster1				= "precinct_group"
global cluster2				= "county_fips"

global absorb				= "county_fips"


* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional.do"




* estimation of differences in effects by year
*---------------------------------------------

	// does not output tables -- for visual inspection only

global iv1					= "pp_has_changed pp_has_changed_x_2016"

cd "${nc_electioneering}"
do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_YearInteraction.do"






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE 6: Drive Time Cross-Section Partisan
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	None
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "closer_5up"
global iv2					= "further_5up"
global iv3					= "pp_has_changed"

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster1				= "precinct_group"
global cluster2				= "county_fips"

global absorb				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_closerfurther"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional.do"

* estimation of differences in effects by year
*---------------------------------------------

	// does not output tables -- for visual inspection only

global iv1					= "closer_5up closer_5up_x_2016 further_5up further_5up_x_2016 pp_has_changed pp_has_changed_x_2016"

cd "${nc_electioneering}"
do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_YearInteraction.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE 8: Race Hetero Drive Time Panel
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Panel
*		Interactions: 	Race
*-------------------------------------------------------------------------------



* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_has_changed_x_nwhite"
global iv2					= "closer_5up further_5up closer_5up_x_nwhite further_5up_x_nwhite"

global cluster1				= "precinct_group"
global absorb				= "ncid"




* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_race"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_PanelOnly_AverageAndCloserFurther_Race.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE ?: Race Hetero Drive Time Cross-Section Panel
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Panel
*		Interactions: 	Race
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

#delimit ;

global iv1 = "pp_has_changed hispanic_x_pp_has_changed black_x_pp_has_changed unknown_x_pp_has_changed other_x_pp_has_changed native_am_x_pp_has_changed asian_x_pp_has_changed multi_race_x_pp_has_changed black unknown other native_am asian multi_race hispanic";

#delimit cr


global iv2					= "closer_5up further_5up closer_5up_x_nwhite further_5up_x_nwhite"

global cluster1				= "precinct_group"
global absorb				= "ncid"


* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_race_disaggregated"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_PanelOnly_AverageAndCloserFurther_Race.do"



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE 8: Non-White Drive Time Cross-Section Partisan
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	Race
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed_x_nwhite"
global iv3					= "nwhite"

global iv4					= "closer_5up"
global iv5					= "further_5up"
global iv6					= "closer_5up_x_nwhite"
global iv7					= "further_5up_x_nwhite"

#delimit ;
global controls_cross_sectional_race = 	"voted_elecday_lag voted_early_lag voted_mailin_lag
										voted_weird_lag age age2 female census_hh_med_income
										party_rep party_una party_lib"
										;  // does not include race variables
#delimit cr

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster2				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_closerfurther_race"

	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional_Race.do"






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


						** IN-TEXT NUMBERS **


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**




*-------------------------------------------------------------------------------
* summary variables for in-text
*-------------------------------------------------------------------------------


* output
*-------

cd "${output}"



* total individuals voting across all years
*------------------------------------------

capture drop tag_indiv_year
capture drop total_indivs_across_years

egen tag_indiv_year = tag(ncid year)
egen total_indivs_across_years = total(tag_indiv_year)   /// this is not unique voters, this is akin to total ballots cast by individual



* percentage that voted absentee
*-------------------------------

sum voted_mailin

	${closef}
	${openf} 	"voted_absentee_percent.tex"	, write replace
	${writef} 	%7.0f (`r(mean)'*100)
	${closef}



* percentage that voted early
*----------------------------

sum voted_early

	${closef}
	${openf} 	"voted_early_percent.tex"	, write replace
	${writef} 	%7.0f (`r(mean)'*100)
	${closef}




* minimum early voting hours
*---------------------------

sum early_vote_total_hours

	${closef}
	${openf} 	"min_early_voting_hours.tex"	, write replace
	${writef} 	%7.0f (`r(min)'*1000)
	${closef}



* std. deviation drive time change
*---------------------------------

sum pp_minutes_driving_change if pp_has_changed == 1

	${closef}
	${openf} 	"conditional_change_drive_time_std.tex"	, write replace
	${writef} 	%7.1f (`r(sd)')
	${closef}


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


						** APPENDIX TABLES **


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**




*-------------------------------------------------------------------------------
* 	APPENDIX TABLE A2: 	Summary statistics
*
*		Description: Also used for Table 1 in the main paper
*-------------------------------------------------------------------------------


* summary statistics
*-------------------

capture drop early_weekend
gen early_weekend = early_vote_saturday_hours + early_vote_sunday_hours


#delimit ;
local variables = "	voted_ANY hispanic voted_early voted_elecday voted_mailin pp_has_changed pp_minutes_driving_change
					census_hh_med_income age age2 female white nwhite black unknown other native_am asian
					multi_race voted_last party_rep party_una party_lib party_dem early_vote_total_hours
					early_vote_number_of_sites early_weekend early_vote_evening_hours
					"

					;

#delimit cr



foreach v of local variables {

	cd "${output}"

	sum `v' if year > 2008

	// mean
	${closef}
	${openf} 	"`v'_mean.tex"	, write replace
	${writef} 	%7.2f (`r(mean)')
	${closef}

	${closef}
	${openf} 	"`v'_mean2.tex"	, write replace
	${writef} 	%7.0f (`r(mean)'*100)
	${closef}


	// sd
	${closef}
	${openf} 	"`v'_sd.tex"	, write replace
	${writef} 	%7.3f (`r(sd)')
	${closef}

	// min
	${closef}
	${openf} 	"`v'_min.tex"	, write replace
	${writef} 	%7.3f (`r(min)')
	${closef}

	// max
	${closef}
	${openf} 	"`v'_max.tex"	, write replace
	${writef} 	%7.3f (`r(max)')
	${closef}

	// N
	${closef}
	${openf} 	"`v'_N.tex"	, write replace
	${writef} 	%14.0fc (`r(N)')
	${closef}

}


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	APPENDIX TABLE D.1:   Non-White Panel Results
*
* 		DV Vote: 		Any, Early, Elec
*		IV: 			pp_has_changed
*		Sample: 		Panel
*		Interactions: 	By Race
*-------------------------------------------------------------------------------



* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_has_changed_x_nwhite"

global cluster1				= "precinct_group"
global absorb				= "ncid"





* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_racehetero"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_Race.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	APPENDIX TABLE D.2:  Race Panel Drive time
*
* 		DV Vote: 		Any
*		IV: 			pp_has_changed, closer, further
*		Sample: 		Panel
*		Interactions: 	By Race
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_has_changed_x_nwhite  closer_5up further_5up closer_5up_x_nwhite further_5up_x_nwhite"

global cluster1				= "precinct_group"
global absorb				= "ncid"





* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_closerfurther_race"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_Race.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE D.3: Race Interactions Cross-Sectional Partisan Polling Place Effects
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling Place has Changed
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	Race
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

#delimit ;
global iv1					= "pp_has_changed hispanic_x_pp_has_changed black_x_pp_has_changed
								unknown_x_pp_has_changed other_x_pp_has_changed
								native_am_x_pp_has_changed asian_x_pp_has_changed
								multi_race_x_pp_has_changed black unknown other native_am
								asian multi_race hispanic"
								;


global controls_cross_sectional_race = 	"voted_elecday_lag voted_early_lag voted_mailin_lag
										voted_weird_lag age age2 female census_hh_med_income
										party_rep party_una party_lib"
										;  // does not include race variables

#delimit cr

global year1				= "year == 2012"
global year2				= "year == 2016"


global cluster2				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_race_all"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional_Race_Appendix.do"







			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE D.3: Race Interactions Drive Time Cross-Section Partisan
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	Race
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed_x_nwhite"
global iv3					= "nwhite"

global iv4					= "closer_5up"
global iv5					= "further_5up"
global iv6					= "closer_5up_x_nwhite"
global iv7					= "further_5up_x_nwhite"

#delimit ;
global controls_cross_sectional_race = 	"voted_elecday_lag voted_early_lag voted_mailin_lag
										voted_weird_lag age age2 female census_hh_med_income
										party_rep party_una party_lib"
										;  // does not include race variables
#delimit cr

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster2				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_closerfurther_race_all"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional_Race.do"




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	APPENDIX TABLE E.1: 	Drive Time Panel with Linear Fits
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Panel
*		Interactions: 	None
*-------------------------------------------------------------------------------

 **to fix**

* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_minutes_driving_change closer_5up further_5up further_5up_x_drive_time closer_5up_x_drive_time"

global cluster1				= "precinct_group"
global absorb				= "ncid"



* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_closefurther_linear"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_CloserFurther_Appendix.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	TABLE E.2: Drive Time Panel with Restriction
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Panel
*		Interactions: 	None
*-------------------------------------------------------------------------------


* preserve
*---------

preserve



* keep
*-----

keep if pp_minutes_driving_change <= 10 & pp_minutes_driving_change >= -10



* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "closer_5up"
global iv2					= "further_5up"
global iv3					= "pp_has_changed"

global cluster1				= "precinct_group"
global absorb				= "ncid"



* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_closefurther_restricted"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_CloserFurther.do"



* restore
*--------

restore





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	APPENDIX E: Drive Time Specifications (NOT PRESENTED)
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer further linear; Closer further quadratic
*		Sample: 		Panel
*		Interactions: 	None
*-------------------------------------------------------------------------------


		** NOT PRESENTED IN THE PAPER **



* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_closer pp_closer_x_drive_time pp_further  pp_further_x_drive_time"
// omitted category is not having pp moved

global cluster1				= "precinct_group"
global absorb				= "ncid"



* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_closefurther_linear"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_CloserFurther_Appendix.do"





* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_closer pp_closer_x_drive_time pp_closer_x_drive_time2 pp_further pp_further_x_drive_time pp_further_x_drive_time2"
// omitted category is not having pp moved

global cluster1				= "precinct_group"
global absorb 				= "ncid"


* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_closefurther_quadratic"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_CloserFurther_Appendix.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	APPENDIX TABLE G.1:  Panel PP Change with Interaction for Lagged Vote
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling place has changed
*		Sample: 		Panel
*		Interactions: 	Lagged Vote
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed"
global iv2					= "elecday_lag_x_pp_change"

global controls_panel_lagvote		= "$controls_crosssection black_x_year hispanic_x_year unknown_x_year other_x_year native_am_x_year asian_x_year multi_race_x_year"

global cluster1				= "precinct_group"


* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_lagged_interaction"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_LagInteraction.do"






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* 	APPENDIX TABLE I.1:   Heterogeneity by Age, Panel
*
*		Description: Polling place change, early and election
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"
global number_of_outcomes	= 3

global iv1					= "pp_has_changed age_u_26_x_pp_has_changed  age_o_76_x_pp_has_changed"

global cluster1				= "precinct_group"
global absorb				= "ncid"




* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_substitution_hetero_age"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_Age.do"



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* 	APPENDIX TABLE I.2:   Heterogeneity by Age, Drive Time
*
*		Description: Polling place change, early and election
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"
global number_of_outcomes	= 3

global iv1					= "pp_has_changed age_u_26_x_pp_has_changed  age_o_76_x_pp_has_changed age_u_26_x_closer_5up age_u_26_x_further_5up age_o_76_x_closer_5up age_o_76_x_further_5up"

global cluster1				= "precinct_group"
global absorb				= "ncid"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_substitution_hetero_age_closerfurther"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_Age.do"




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	APPENDIX TABLE I.3: Cross-Sectional Partisan Polling Place Effects by Age
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling Place has Changed
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	Income
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed age_u_26_x_pp_has_changed  age_o_76_x_pp_has_changed age_u_26 age_o_76"

#delimit ;
global controls_crosssection_age = 	"voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag
									female black hispanic unknown other native_am asian
									multi_race census_hh_med_income party_rep party_una party_lib"
							;
#delimit cr

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster2				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_age"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional_Age.do"






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	APPENDIX TABLE I.4: Drive Time Cross-Section Partisan by Age
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	Income
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed age_u_26_x_pp_has_changed  age_o_76_x_pp_has_changed age_u_26 age_o_76 age_u_26_x_closer_5up age_u_26_x_further_5up age_o_76_x_closer_5up age_o_76_x_further_5up"

#delimit ;
global controls_crosssection_age = 	"voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag
									female black hispanic unknown other native_am asian
									multi_race census_hh_med_income party_rep party_una party_lib"
							;
#delimit cr

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster2				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_closerfurther_age"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional_Age.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* 	APPENDIX TABLE K.1:   Heterogeneity by Income, Panel
*
*		Description: Polling place change, early and election
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"
global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_has_changed_x_income"
global iv2					= "pp_has_changed pp_has_changed_x_income census_hh_med_income"

global cluster1				= "precinct_group"
global absorb				= "ncid"




* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_substitution_hetero_income"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_Income.do"



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* 	APPENDIX TABLE K.2:   Heterogeneity by Income, Drive Time
*
*		Description: Polling place change, early and election
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"
global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_has_changed_x_income closer_5up further_5up closer_5up_x_income further_5up_x_income"

global cluster1				= "precinct_group"
global absorb				= "ncid"




* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_substitution_hetero_income_closerfurther"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly_Income.do"




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	APPENDIX TABLE K.3: Cross-Sectional Partisan Polling Place Effects by Income
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling Place has Changed
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	Income
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_has_changed_x_income census_hh_med_income"

#delimit ;
global controls_crosssection_income = 	"age age2 voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag
										female black hispanic unknown other native_am asian
										multi_race party_rep party_una party_lib"
								;
#delimit cr

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster2				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_income"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional_Income.do"






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
*	APPENDIX TABLE K.4: Drive Time Cross-Section Partisan by Income
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Closer, Further
*		Sample: 		Cross-sectional (Partisan)
*		Interactions: 	Income
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed pp_has_changed_x_income closer_5up further_5up closer_5up_x_income further_5up_x_income"

#delimit ;
global controls_crosssection_income = 	"age age2 voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag
										female black hispanic unknown other native_am asian
										multi_race party_rep party_una party_lib"
								;
#delimit cr

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster2				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_crosssection_closerfurther_income"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_6Cols_CrossSectional_Income.do"




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	TABLE : Regressing on leads (does 2016 polling place change predict 2012 behavior)
*
* 		DV Vote: 		Any, ElectionDay, Early
*		IV: 			Polling place has changed
*		Sample: 		Panel
*		Interactions: 	None
*-------------------------------------------------------------------------------



* globals for specifications
*---------------------------

clean_globals


	// generate an indicator = 1 if a voters polling place was changed between 20012 and 2016
	capture drop test
	capture drop pp_has_changed_12_16

gen test = 1   		if year == 2016 & pp_has_changed == 1
replace test = 0 	if test != 1
bysort ncid: egen pp_has_changed_12_16 = max(test)
drop test

label var pp_has_changed_12_16 "$\Delta$\emph{Polling Place (lead, 2012-2016)}"



global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed_12_16"

global year1				= "year == 2012"
// global year2				= "year == 2016"

global cluster1				= "precinct_group"
global cluster2				= "county_fips"

global absorb				= "county_fips"



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_lead"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_Lead.do"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* APPENDIX O: Anaysis of close movers (within-precinct movers)
*-------------------------------------------------------------------------------


* data
*-----

cd $nc_electioneering

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/90_voter_panel_wallanalysisvars_w_movers_dta.zip, clear
}
else {
    use 20_intermediate_files/90_voter_panel_10pctsample_wallanalysisvars_w_movers.dta, clear
}


* gen move interaction
*---------------------

capture drop pp_change_x_ppsame
gen pp_change_x_ppsame = voter_ppsame_move * pp_has_changed
label var pp_change_x_ppsame "\emph{StableAssignmentMove} x $ \Delta PollingPlace$"
label var voter_ppsame_move "\emph{StableAssignmentMove}"


* globals for specifications
*---------------------------

clean_globals


global dv1					= "voted_elecday"
global dv2					= "voted_early"
global dv3					= "voted_ANY"

global number_of_outcomes	= 3

global iv1					= "pp_has_changed"
global iv2					= "pp_change_x_ppsame"
global iv3					= "voter_ppsame_move"

global cluster1				= "precinct_group"
global absorb				= "ncid"


* set the data
*-------------

tsset voter_index election_index



* estimate the specifications and save the output
*------------------------------------------------

global filename				= "table_pp_panel_winprecinctmovers"



	cd "${nc_electioneering}"
	do "10_code/50_effect_of_pp_change/Specifications_Paper_3Cols_PanelOnly.do"




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**

						** end of do file **
