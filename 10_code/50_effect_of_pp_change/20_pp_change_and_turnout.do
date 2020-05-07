
    ************************************************************************
    **
    **
    **        PROJECT AUTHORS:    CLINTON, EUBANK, FRESH & SHEPHERD
    **        DO FILE AUTHOR:        EUBANK
    **        DATE BEGUN:         February ?, 2018
    **
    **        PROJECT:             NC Electioneering
    **        DETAILS:
    **
    **        UPDATES:  Reads in full panel, reshapes, sets panel vars.
    **
    **
    **        VERSION:             Stata 14
    **
    **
    *************************************************************************



            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------


clear
set more off

* set the directory
*------------------

cd $nc_electioneering

* use the data
*-------------

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/60_voter_panel_long_w_analysisvars_no_movers_dta.zip, clear
}
else {
    use 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_no_movers_.dta, clear

}


* Helper Vars
*-------------

gen black = race != 0
gen age2 = age^2

sort voter_index election_index
gen voted_last = L.voted_ANY


* Panel: Individual FE
*-----------------------------------------------------------------

*	Voters and non-voters included
xi:areg voted_ANY pp_has_changed  i.year*i.race, a(ncid)

* Cross-Sections
*-----------------------------------------------------------------

*	Voters and non-voters included

local demo_controls = "age age2 census_hh_med_income female i.race voted_last i.party"
foreach year in 2012 2016 {
    display "`year'"
    xi:areg voted_ANY pp_has_changed `demo_controls' if year == `year', a(county_fips)
}

*************
*
* Non-white voters
*
*************

* Panel: Individual FE
*-----------------------------------------------------------------

*	Voters and non-voters included
xi:areg voted_ANY pp_has_changed  i.year*i.race if race !=0, a(ncid)

* Cross-Sections
*-----------------------------------------------------------------

*	Voters and non-voters included

local demo_controls = "age age2 census_hh_med_income female i.race voted_last i.party"
foreach year in 2012 2016 {
    display "`year'"
    xi:areg voted_ANY pp_has_changed `demo_controls' if year == `year' & race !=0, a(county_fips)
}
