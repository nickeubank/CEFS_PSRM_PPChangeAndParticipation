
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


* preliminaries
*--------------

clear
set more off



* set the directory
*------------------

cd $nc_electioneering



* use the data
*-------------

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/30_voter_panel_full_dta.zip, clear
}
else {
    use 20_intermediate_files/30_voter_panel_10pctsample.dta, clear
}



            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* assert that the voted variables properly propagated
*-------------------------------------------------------------------------------

    /*
        Quick check to make sure my changes to "voted" vars propagated.
        Initially accidentally made same in all years.

    */


* take the mean of voted and check the 75th percentile isn't 0 or 1
*------------------------------------------------------------------

egen mean_vote = rowmean(ts_voted_* )
sum mean_vote, d
assert (r(p75) != 0) &  (r(p75) != 1)





            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* reshape and set the data as a time series
*-------------------------------------------------------------------------------

    /*
        Gonna limit to 2008, 2012, 2016. We have 2014 (for off cycle analysis)
        and turnout for lots more years. But this is our balanced consistent
        panel, so let's start with this.

    */


* only keep the presidential election years
*------------------------------------------

keep *2008 *2012 *2016 ncid



* decode value-labeled variables before stacking if value-to-label
* isn't stable year to year (like county). See Issue #41.
*-----------------------------------------------------------------

foreach year in 2008 2012 2016 {
    foreach bad_labeled_var in county city {
        rename `bad_labeled_var'_`year' temp_`bad_labeled_var'_`year'
        decode temp_`bad_labeled_var'_`year', gen(`bad_labeled_var'_`year')
        drop temp_`bad_labeled_var'_`year'
    }
}

* confirm others are safe -- same codes across years
*---------------------------------------------------
foreach labeled_var in female party hispanic race voter_status accuracy_type ts_voted ncsbe_voted {
    foreach year in 2008 2012 2016 {
        levelsof `labeled_var'_`year', local(levels)
        local lbe_`year' : value label `labeled_var'_`year'
    }
        foreach l of local levels {
            local 2008: label `lbe_2008' `l'
            local 2012: label `lbe_2012' `l'
            local 2016: label `lbe_2016' `l'
            display "`2008'"
            display "`2016'"
            assert "`2008'" == "`2012'"
            assert "`2012'" == "`2016'"

        }
}



* get stems of all vars for panel (too many to hand enter)
*---------------------------------------------------------

local stems = ""

foreach var of varlist *_2016 {

    local nextstem = regexr("`var'", "2016", "")
    local stems = "`stems' `nextstem'"

}



* display and reshape the stems
*------------------------------

display "`stems'"
reshape long `stems',  i(ncid) j(year)



* check county vars match to one and only one fips each
* Some stupid geocodes put people in county with same
* name in WRONG STATE, so dont check for those.
* We'll drop the out-of-staters later.
*------------------------------------------------------

gen temp_state = floor(county_fips/1000)
bysort county_: egen temp_min_fips = min(county_fips) if temp_state != 37 & temp_state != .
bysort county_: egen temp_max_fips = max(county_fips) if temp_state != 37 & temp_state != .
assert temp_min_fips == temp_max_fips
drop temp_*_fips
drop temp_state



* label the master identifier variable
*-------------------------------------

label var ncid "north carolina voter id code, master identifier"

* rename all of the variables to drop lagging underscore
*-------------------------------------------------------

renvars *_, postdrop(1)



            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* set up the panel (including time series set the data)
*-------------------------------------------------------------------------------


* generate election indices for each of the three election years
*---------------------------------------------------------------

gen election_index = .
label var election_index "1,2,3 numeric index for 2008, 2012, 2016 elections for tsset"

replace election_index = 1         if year == 2008
replace election_index = 2         if year == 2012
replace election_index = 3         if year == 2016



* voter index variable
*---------------------

egen voter_index = group(ncid)
label var voter_index "group ID for NCID for tsset; use NCID as identifier"



* time series set the data
*-------------------------

tsset voter_index election_index



* order variables
*----------------

order ncid voter_index election_index year



* sort the data
*--------------

sort voter_index election_index



            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* save the data
*-------------------------------------------------------------------------------


* save the data
*--------------

cd $nc_electioneering

if "$sample_size" == "full" {
    zipsave 20_intermediate_files/40_voter_panel_long_dta.zip, replace
}
else {
    save 20_intermediate_files/40_voter_panel_10pctsample_long.dta, replace
}







            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **

             ** end of 00_reshape_long.do **
