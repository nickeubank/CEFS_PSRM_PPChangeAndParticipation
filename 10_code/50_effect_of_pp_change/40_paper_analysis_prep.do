
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
    **        UPDATES:  		  Paper output data.
    **
    **
    **        VERSION:             Stata 14
    **
    **
    *************************************************************************




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------


clear
set more off



* set the directory
*------------------

cd $nc_electioneering


local datasettypes = "no w"

foreach Q of local datasettypes {


* use the data
*-------------

if "$sample_size" == "full" {
    zipuse "20_intermediate_files/60_voter_panel_long_w_analysisvars_`Q'_movers_dta.zip", clear
}
else {
    use "20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_`Q'_movers.dta", clear

}




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
* new variables
*-------------------------------------------------------------------------------


* additional analysis variables
*------------------------------

gen black 	= race != 0
gen age2 	= age^2



* voted in last election
*-----------------------

sort voter_index 	election_index
gen voted_last = L.voted_ANY



* change in driving time from last election
*------------------------------------------

sort voter_index 	election_index
gen pp_minutes_driving_change = D.pp_minutes_driving



* replace change in drive time to zero if there is no polling place change
*-------------------------------------------------------------------------

replace pp_minutes_driving_change = 0 	if pp_has_changed == 0



* county
*-------

gen county_name = county
label var county_name "county name as string"
replace county_name = regexr(county_name, "( County)", "")



* pull out i.race
*----------------

gen white		= 1  if race == 0
gen unknown		= 1  if race == 2
gen other		= 1  if race == 3
gen native_am	= 1  if race == 4
gen asian		= 1  if race == 5
gen multi_race	= 1  if race == 6
gen hispanic 	= 1	 if race == 7

local races = "white unknown other native_am asian multi_race hispanic"

foreach race of local races {

		replace `race' = 0 	if `race' == .

}



* non-white and interaction
*--------------------------

	// non-white = 1 (incl. hispanic); non-white = 0 (white non-hispanic only)

gen nwhite 		= 1 			if white == 0
replace nwhite 	= 0 			if nwhite == .

gen pp_has_changed_x_nwhite = nwhite * pp_has_changed

gen nwhite_x_year = nwhite * year



* income interaction
*-------------------

replace census_hh_med_income = census_hh_med_income / 10000

gen pp_has_changed_x_income = census_hh_med_income  * pp_has_changed




* pull out i.party
*-----------------

gen party_dem = 1 if party == 0
gen party_rep = 1 if party == 1
gen party_una = 1 if party == 2
gen party_lib = 1 if party == 3

local parties = "dem rep una lib"

foreach party of local parties {

		replace party_`party' = 0 	if party_`party' == .

}

foreach i in dem rep una lib {
    gen pp_has_changed_x_party_`i' = party_`i' * pp_has_changed
}



* year 2016
*----------

gen year_2016 = 1 			if year == 2016
replace year_2016 = 0 		if year_2016 ==.




* race by year
*-------------

local races = "white hispanic black unknown other native_am asian multi_race"

foreach race of local races {

	gen `race'_x_year 			= `race' * year_2016
	gen `race'_x_pp_has_changed = `race' * pp_has_changed

}



* interaction with change in drive time
*--------------------------------------

gen pp_chng_x_chng_drive_time 	= pp_has_changed * pp_minutes_driving_change
gen pp_chng_x_chng_drive_time2 	= pp_chng_x_chng_drive_time*pp_chng_x_chng_drive_time




* early voting
*-------------

replace early_vote_total_hours 		= early_vote_total_hours / 1000
replace early_vote_evening_hours 	= early_vote_evening_hours / 1000
replace early_vote_saturday_hours 	= early_vote_saturday_hours / 1000
replace early_vote_sunday_hours 	= early_vote_sunday_hours / 1000


gen pp_x_earlyloc =  pp_has_changed * early_vote_number_of_sites
gen pp_x_earlyhours = pp_has_changed * early_vote_total_hours




* move closer or further binary
*------------------------------

gen pp_further = pp_has_changed
recode pp_further (1=0) 		if pp_minutes_driving_change < 0

gen pp_closer = pp_has_changed
recode pp_closer (1=0) 			if pp_minutes_driving_change > 0



* drive time squared
*-------------------

gen pp_minutes_driving_change2	= pp_minutes_driving_change^2



* move closer further interaction
*--------------------------------

gen pp_further_x_drive_time		= pp_further * pp_minutes_driving_change
gen pp_closer_x_drive_time		= pp_closer  * pp_minutes_driving_change

gen pp_further_x_drive_time2	= pp_further * pp_minutes_driving_change2
gen pp_closer_x_drive_time2		= pp_closer  * pp_minutes_driving_change2



* closer further by nonwhite
*---------------------------

gen closer_x_nwhite 	= nwhite * pp_closer
gen further_x_nwhite	= nwhite * pp_further





* closer or further extremes of distribution
*-------------------------------------------

quietly sum pp_chng_x_chng_drive_time, d

gen MuchCloser = 1 			if pp_chng_x_chng_drive_time < r(p25)
gen MuchFurther = 1 		if pp_chng_x_chng_drive_time > r(p75)

replace MuchCloser = 0 		if MuchCloser==.
replace MuchFurther = 0 	if MuchFurther==.


gen closer_0_5		= 1		if pp_chng_x_chng_drive_time < 0 & pp_chng_x_chng_drive_time >= -5
gen closer_5_10		= 1		if pp_chng_x_chng_drive_time < 5 & pp_chng_x_chng_drive_time >= -10
gen closer_5up		= 1		if pp_chng_x_chng_drive_time <= -5
gen closer_10up		= 1		if pp_chng_x_chng_drive_time < -10

gen further_0_5		= 1		if pp_chng_x_chng_drive_time > 0 & pp_chng_x_chng_drive_time <= 5
gen further_5_10	= 1		if pp_chng_x_chng_drive_time > 5 & pp_chng_x_chng_drive_time <= 10
gen further_5up		= 1		if pp_chng_x_chng_drive_time >= 5
gen further_10up	= 1		if pp_chng_x_chng_drive_time > 10

replace closer_0_5 		= 0 	if closer_0_5 == .
replace closer_5_10 	= 0 	if closer_5_10 == .
replace closer_5up 		= 0 	if closer_5up == .
replace closer_10up 	= 0 	if closer_10up== .
replace further_0_5 	= 0 	if further_0_5 == .
replace further_5_10 	= 0 	if further_5_10 == .
replace further_5up 	= 0 	if further_5up == .
replace further_10up 	= 0 	if further_10up == .


gen closer_0_5_x_drive_time		= closer_0_5 * pp_chng_x_chng_drive_time
gen closer_5up_x_drive_time		= closer_5up * pp_chng_x_chng_drive_time
gen further_0_5_x_drive_time	= further_0_5 * pp_chng_x_chng_drive_time
gen further_5up_x_drive_time	= further_5up * pp_chng_x_chng_drive_time



* closer/further by race
*-----------------------

gen closer_5up_x_nwhite 		= closer_5up * nwhite
gen further_5up_x_nwhite 		= further_5up * nwhite




* 2016 interaction
*-----------------

gen pp_has_changed_x_2016 	= pp_has_changed * year_2016
gen closer_5up_x_2016 		= closer_5up * year_2016
gen further_5up_x_2016 		= further_5up * year_2016



* time series set the data to generate lag in election day voting type
*---------------------------------------------------------------------

tsset voter_index election_index

gen voted_elecday_lag 	= L.voted_elecday
gen voted_early_lag		= L.voted_early
gen voted_mailin_lag 	= L.voted_mailin
gen voted_weird_lag		= L.voted_weird


gen elecday_lag_x_pp_change = voted_elecday_lag * pp_has_changed



* age categories
*---------------

bysort ncid: egen age_2016 = max(age)


gen age_u_26 = 1 		if age_2016 <= 26
replace age_u_26 = 0	if age_u_26 == .

gen age_27_50 = 1		if age_2016 >= 27 & age_2016 <= 50
replace age_27_50 = 0	if age_27_50 == .

gen age_51_75 = 1		if age_2016 >= 51 & age_2016 <= 75
replace age_51_75 = 0	if age_51_75 == .

gen age_o_76 = 1 		if age_2016 >= 76
replace age_o_76 = 0	if age_o_76 == .



* age interactions
*-----------------

local variables = "age_u_26 age_27_50 age_51_75 age_o_76"

foreach v of local variables {

	gen `v'_x_pp_has_changed = `v' * pp_has_changed

}





* non-panel variables
*--------------------

capture drop test
gen test = 1 				if year == 2012 & pp_has_changed == 1
replace test = 0 			if test == .
bysort ncid: egen pp_change_2008_2012 = max(test)
drop test

gen test = 1				if year == 2016 & pp_has_changed == 1
replace test = 0 			if test == .
bysort ncid: egen pp_change_2012_2016 = max(test)
drop test



* voter tags
*-----------

egen tag_voter_yr = tag(ncid year)
bysort year: egen total_voter_yr = total(tag_voter_yr)

egen tag_voter = tag(ncid)
egen total_voter = total(tag_voter)




* wide variables for type of vote
*--------------------------------

	// voted early by year
	//--------------------
capture drop test
gen test = 1 				if year == 2008 & voted_early == 1
bysort ncid: egen early_2008 = max(test)
replace early_2008 = 0		if early_2008 == .
drop test

gen test = 1 				if year == 2012 & voted_early == 1
bysort ncid: egen early_2012 = max(test)
replace early_2012 = 0		if early_2012 == .
drop test

gen test = 1 				if year == 2016 & voted_early == 1
bysort ncid: egen early_2016 = max(test)
replace early_2016 = 0		if early_2016 == .
drop test


	// voted election day by year
	//---------------------------
gen test = 1 				if year == 2008 & voted_elecday == 1
bysort ncid: egen elec_2008 = max(test)
replace elec_2008 = 0		if elec_2008 == .
drop test

gen test = 1 				if year == 2012 & voted_elecday == 1
bysort ncid: egen elec_2012 = max(test)
replace elec_2012 = 0		if elec_2012 == .
drop test

gen test = 1 				if year == 2016 & voted_elecday == 1
bysort ncid: egen elec_2016 = max(test)
replace elec_2016 = 0		if elec_2016 == .
drop test


	// voted any by year
	//------------------
gen test = 1 				if year == 2008 & voted_ANY == 1
bysort ncid: egen any_2008 = max(test)
replace any_2008 = 0		if any_2008 == .
drop test

gen test = 1 				if year == 2012 & voted_ANY == 1
bysort ncid: egen any_2012 = max(test)
replace any_2012 = 0		if any_2012 == .
drop test

gen test = 1 				if year == 2016 & voted_ANY == 1
bysort ncid: egen any_2016 = max(test)
replace any_2016 = 0		if any_2016 == .
drop test


	// did not vote by year
	//---------------------
gen test = 1 				if year == 2008 & voted_ANY == 0
bysort ncid: egen no_2008 = max(test)
replace no_2008 = 0		if no_2008 == .
drop test

gen test = 1 				if year == 2012 & voted_ANY == 0
bysort ncid: egen no_2012 = max(test)
replace no_2012 = 0		if no_2012 == .
drop test

gen test = 1 				if year == 2016 & voted_ANY == 0
bysort ncid: egen no_2016 = max(test)
replace no_2016 = 0		if no_2016 == .
drop test




* vote type for 2008 and 2012
*----------------------------

gen elec_elec = 1			if elec_2008 == 1 	& elec_2012 == 1
replace elec_elec = 0 		if elec_elec == .

gen elec_early = 1			if elec_2008 == 1  & early_2012 == 1
replace elec_early = 0 		if elec_early == .

gen early_elec = 1			if early_2008 == 1 	& elec_2012 == 1
replace early_elec = 0 		if early_elec == .

gen early_early = 1			if early_2008 == 1 	& early_2012 == 1
replace early_early = 0 	if early_early == .

gen any_any = 1				if any_2008 == 1 	& any_2012 == 1
replace any_any = 0 		if any_any == .

gen no_elec = 1				if no_2008 == 1 	& elec_2012 == 1
replace no_elec = 0 		if no_elec == .

gen no_no = 1				if no_2008 == 1 	& no_2012 == 1
replace no_no = 0 			if no_no == .



* closer further by income
*-------------------------

gen closer_5up_x_income 	= closer_5up * census_hh_med_income
gen further_5up_x_income 	= further_5up * census_hh_med_income



* age interactions
*-----------------

local variables = "age_u_26 age_27_50 age_51_75 age_o_76"

foreach v of local variables {

	gen `v'_x_closer_5up = `v' * closer_5up
	gen `v'_x_further_5up = `v' * further_5up

}



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* county by year interactions
*-------------------------------------------------------------------------------

* year
*-----

gen year_2008 = 1 if year == 2008
gen year_2012 = 1 if year == 2012
//gen year_2016 = 1 if year == 2016



* county
*-------

tab county, gen(c_)



* interact
*---------

local years = "2008 2012 2016"

foreach y of local years {

	replace year_`y' = 0  if year_`y' == .

	forvalues x = 1/100 {

		gen c_`x'_x_`y' = c_`x' * year_`y'
		label var c_`x'_x_`y' "county `x' interacted with year `y'"

	}


}


* drop
*-----

drop c_1 - c_100

	// I guess maybe we don't need all of these...?
drop c_1_x_2008 - c_100_x_2012
drop c_1_x_2016




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* stable precinct number
*-------------------------------------------------------------------------------

* generate last precinct as a stable precinct
*--------------------------------------------

gen precinct_last = .
label var precinct_last "last precinct voter was in (2016) applied to all years"

replace precinct_last = precinct_id_withinyear if year == 2016
sort ncid precinct_last
replace precinct_last = precinct_last[_n-1] ///
		if precinct_last == . & precinct_last[_n-1] != . & ncid[_n] == ncid[_n-1]




* generate group over all precincts that an individual has been in
*-----------------------------------------------------------------

gen test = precinct_id_withinyear if year == 2008
bysort ncid:  egen precinct_2008 = max(test)
drop test

gen test = precinct_id_withinyear if year == 2012
bysort ncid: egen precinct_2012 = max(test)
drop test

gen test = precinct_id_withinyear if year == 2016
bysort ncid:  egen precinct_2016 = max(test)
drop test

egen precinct_group = group(precinct_2008 precinct_2012 precinct_2016)


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* change variable labels for table output
*-------------------------------------------------------------------------------


* label
*------

	// main variable
	//--------------
label var pp_has_changed 				"$\Delta$\emph{PollingPlace} $(\hat{\beta})$"


	// drive time
	//-----------
label var pp_minutes_driving_change		"$\Delta$\emph{DriveTime}"
label var pp_further 					"$\Delta$\emph{Further}"
label var pp_closer 					"$\Delta$\emph{Closer}"
label var closer_5up 					"$\Delta$\emph{MuchCloser} $(\hat{\lambda})$"
label var further_5up 					"$\Delta$\emph{MuchFurther} $(\hat{\delta})$"


	// drive time x race
	//------------------
label var closer_x_nwhite				"$\Delta Closer \cdot$\emph{NonWhite}"
label var further_x_nwhite				"$\Delta Further \cdot$\emph{NonWhite}"


	// drive time x income
	//--------------------
label var closer_5up_x_income			"$\Delta MuchCloser \cdot$\emph{Income}"
label var further_5up_x_income			"$\Delta MuchFurther \cdot$\emph{Income}"


	// polling place x race/income
	//----------------------------
label var pp_has_changed_x_nwhite		"$\Delta PollingPlace \cdot$\emph{NonWhite}"
label var pp_has_changed_x_income		"$\Delta$\emph{PollingPlace}$\cdot Income$"


	// early voting
	//-------------
label var pp_x_earlyloc 				"$\Delta PollingPlace \cdot EarlyLocs$ $(\hat{\delta})$"
label var early_vote_number_of_sites	"\emph{Early Vote Locations}"
label var pp_x_earlyhours 				"$\Delta PollingPlace \cdot EarlyHours$ $(\hat{\delta})$"
label var early_vote_total_hours		"\emph{EarlyHours} $(\hat{\psi})$"


	// covariates
	//-----------
label var age							"\emph{Age}"
label var age2							"\emph{Age}$^{2}$"
label var voted_last					"\emph{VotedLastElec}"
label var female						"\emph{Female}"
label var census_hh_med_income			"\emph{Income}"


	// race
	//-----
label var black 						"\emph{Black}"
label var hispanic 						"\emph{Hispanic}"
label var white 						"\emph{White}"
label var unknown 						"\emph{UnknownRace}"
label var other 						"\emph{OtherRace}"
label var native_am 					"\emph{NativeAm}"
label var asian 						"\emph{Asian}"
label var multi_race 					"\emph{MultiRace}"
label var nwhite 						"\emph{NonWhite}"


	// race x year interactions
	//-------------------------
label var white_x_year  				"\emph{White}$\cdot 2016$"
label var black_x_year 					"\emph{Black}$\cdot 2016$"
label var hispanic_x_year 				"\emph{Hispanic}$\cdot 2016$"
label var unknown_x_year 				"\emph{Unknown}$\cdot 2016$"
label var other_x_year 					"\emph{Other}$\cdot 2016$"
label var native_am_x_year 				"\emph{NativeAm}$\cdot 2016$"
label var asian_x_year 					"\emph{Asian}$\cdot 2016$"
label var multi_race_x_year				"\emph{MultiRace}$\cdot 2016$"
label var nwhite_x_year					"\emph{NonWhite}$\cdot 2016$"


	// race x polling place change interactions
	//-----------------------------------------
label var white_x_pp_has_changed  		"$\Delta$\emph{PollingPlace}$\cdot White$"
label var black_x_pp_has_changed 		"$\Delta$\emph{PollingPlace}$\cdot Black$"
label var unknown_x_pp_has_changed 		"$\Delta$\emph{PollingPlace}$\cdot Unknown$"
label var other_x_pp_has_changed 		"$\Delta$\emph{PollingPlace}$\cdot Other$"
label var native_am_x_pp_has_changed 	"$\Delta$\emph{PollingPlace}$\cdot NativeAm$"
label var asian_x_pp_has_changed 		"$\Delta$\emph{PollingPlace}$\cdot Asian$"
label var multi_race_x_pp_has_changed	"$\Delta$\emph{PollingPlace}$\cdot MultiRace$"
label var hispanic_x_pp_has_changed		"$\Delta$\emph{PollingPlace}$\cdot Hispanic$"


	// party
	//------
label var party_dem 					"\emph{Democrat}"
label var party_rep 					"\emph{Republican}"
label var party_una						"\emph{Unaffiliated}"
label var party_lib 					"\emph{Libertarian}"

    // party x polling place change interactions
    //------------------------------------------

label var pp_has_changed_x_party_dem 					"$\Delta$\emph{PollingPlace}$\cdot$\emph{Dem}$"
label var pp_has_changed_x_party_rep 					"$\Delta$\emph{PollingPlace}$\cdot$\emph{Rep}"
label var pp_has_changed_x_party_una 					"$\Delta$\emph{PollingPlace}$\cdot$\emph{Unaffil}"
label var pp_has_changed_x_party_lib 					"$\Delta$\emph{PollingPlace}$\cdot$\emph{Lib}"



	// year
	//-----
label var year_2016						"\emph{year2016}"


	// previous vote type lag
	//-----------------------
label var voted_elecday_lag  			"\emph{LagElecDayVoter}"
label var voted_early_lag				"\emph{LagEarlyVoter}"
label var voted_mailin_lag 				"\emph{LagMailInVoter}"
label var voted_weird_lag				"\emph{LagProvisionalVoter}"

label var elecday_lag_x_pp_change		"\emph{LagElecDayVoter}$\cdot \Delta PollingPlace$"


	// age dummies
	//------------
label var age_u_26 						"\emph{Age <26}"
label var age_27_50 					"\emph{Age 27-50}"
label var age_51_75 					"\emph{Age 51-75}"
label var age_o_76 						"\emph{Age 76+}"


	// age x polling place change
	//---------------------------
label var age_u_26_x_pp_has_changed 	"$\Delta PollingPlace \cdot$\emph{Age <26}"
label var age_27_50_x_pp_has_changed 	"$\Delta PollingPlace \cdot$\emph{Age 27-50}"
label var age_51_75_x_pp_has_changed 	"$\Delta PollingPlace \cdot$\emph{Age 51-75}"
label var age_o_76_x_pp_has_changed		"$\Delta PollingPlace \cdot$\emph{Age 76+}"


	// age x drive time
	//-----------------
label var age_u_26_x_closer_5up 	"$\Delta MuchCloser \cdot$\emph{Age <26}"
label var age_27_50_x_closer_5up 	"$\Delta MuchCloser \cdot$\emph{Age 27-50}"
label var age_51_75_x_closer_5up 	"$\Delta MuchCloser \cdot$\emph{Age 51-75}"
label var age_o_76_x_closer_5up		"$\Delta MuchCloser \cdot$\emph{Age 76+}"

label var age_u_26_x_further_5up 	"$\Delta MuchCloser \cdot$\emph{Age <26}"
label var age_27_50_x_further_5up 	"$\Delta MuchCloser \cdot$\emph{Age 27-50}"
label var age_51_75_x_further_5up 	"$\Delta MuchCloser \cdot$\emph{Age 51-75}"
label var age_o_76_x_further_5up	"$\Delta MuchCloser \cdot$\emph{Age 76+}"


	// closer/further (amount) x drive time
	//-------------------------------------
label var closer_0_5_x_drive_time 		"$\Delta$\emph{Closer}$\cdot DriveTime$"
label var closer_5up_x_drive_time 		"$\Delta$\emph{MuchCloser}$\cdot DriveTime$"
label var further_0_5_x_drive_time 		"$\Delta$\emph{Further}$\cdot DriveTime$"
label var further_5up_x_drive_time		"$\Delta$\emph{MuchFurther}$\cdot DriveTime$"


	// closer/further (binary) x drive time
	//-------------------------------------
label var pp_further_x_drive_time		"$\Delta$\emph{Further}$\cdot \Delta DriveTime$"
label var pp_closer_x_drive_time		"$\Delta$\emph{Closer}$\cdot \Delta DriveTime$"
label var pp_further_x_drive_time2		"$\Delta$\emph{Further}$\cdot \Delta DriveTime^{2}$"
label var pp_closer_x_drive_time2		"$\Delta$\emph{Closer}$\cdot \Delta DriveTime^{2}$"



	// drive time by race
	//-------------------
label var closer_5up_x_nwhite			"$\Delta$\emph{MuchCloser}$\cdot NonWhite$"
label var further_5up_x_nwhite			"$\Delta$\emph{MuchFurther}$\cdot NonWhite$"





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
*	Save temp
*-------------------------------------------------------------------------------


* save
*-----

cd $nc_electioneering

if "$sample_size" == "full" {
    zipsave "20_intermediate_files/90_voter_panel_wallanalysisvars_`Q'_movers_dta.zip", replace
}
else {
    save "20_intermediate_files/90_voter_panel_10pctsample_wallanalysisvars_`Q'_movers.dta", replace
}


}


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**

						** end of do file **
