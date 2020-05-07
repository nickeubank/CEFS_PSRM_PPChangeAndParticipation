
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
    **        UPDATES: Subsets our panel to people who were accurately geocoded,
    **                 can be matched to a polling place, and have voting histories.
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
* Helper Functions
*-------------------------------------------------------------------------------


capture program drop export_sample_size
program define export_sample_size
    local name="`1'"
    duplicates report ncid
    global `name' = r(unique_value)

    * Scale by 10 since working with sample.
    * Change if run on full sample or when submitting.

    if "$sample_size" == "10percent" {
        global `name' = ${`name'} * 10
        assert ${`name'} < 7000000
    }

    * Then use this code to set the formatting.
    * This says "show it with 2 decimal places."
    * Display lets you check it.

    local cleaned_statistic: display %12.0fc ${`name'}
    display "`cleaned_statistic'"

    * Write to disk.
    * This syntax looks odd, but what it's doing is creating
    * a "handle" to a file, writing to that handle,
    * then closing the file when done.

    file open myfile using $nc_electioneering/50_results_$sample_size/`name'.tex, write text replace
    file write myfile "`cleaned_statistic'"
    file close myfile

    display "Exported `cleaned_statistic'"
end

capture program drop export_share
program define export_share
    local name="`1'"
    local numerator=`2'
    local denominator=`3'

    * Then use this code to set the formatting.
    * This says "show it with 2 decimal places."
    * Display lets you check it.
    local share = (`numerator' / `denominator') * 100
    assert `share' <= 100
    local cleaned_statistic: display %9.1fc `share'
    display "`cleaned_statistic'"

    * Write to disk.
    * This syntax looks odd, but what it's doing is creating
    * a "handle" to a file, writing to that handle,
    * then closing the file when done.

    file open myfile using $nc_electioneering/50_results_$sample_size/`name'.tex, write text replace
    file write myfile "`cleaned_statistic'"
    file close myfile

    display "Exported `cleaned_statistic'"
end





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
    zipuse 20_intermediate_files/40_voter_panel_long_dta.zip, clear
}
else {
    use 20_intermediate_files/40_voter_panel_10pctsample_long.dta, clear
}






            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* Sample Restrictions!
*
* 0) Before baseline, drop anyone who is NEVER eligible (deadweight)
* 1) Must be eligible to vote in 2008 and 2012
* 2) Must have voter history data
* 3) Must have address accurately geocoded
* 4) Must have associated polling place geocoded and identified.
*
*-------------------------------------------------------------------------------

*------------------------------------------------------------------------------------
* 1) generate a tag for individuals in our preferred sample, and restrict the sample
*------------------------------------------------------------------------------------


* Can vote in at least one election
*----------------------------------

gen temp_can_vote = (voter_status == 0 | voter_status == 2 | voter_status == 4)
bysort ncid: egen temp_years_can_vote = sum(temp_can_vote)
gen temp_cantvote = temp_years_can_vote == 0
sum temp_cantvote, meanonly
assert r(mean) < 0.3
drop if temp_cantvote == 1
drop temp_cantvote temp_years_can_vote temp_can_vote

* Export sample size
export_sample_size "sample_canvote_any"



// tag if individual appears in 2008 or 2012; this is based on github issue #36 conversation (2/19/2018)

* generate sample variable
*-------------------------

    // was individual active, inactive or temporary in 2008 or 2012
gen tag_08_12 = 1          if     (voter_status == 0 | voter_status == 2 | voter_status == 4) & ///
                            (year == 2008 | year == 2012)
replace tag_08_12 = 0     if     tag_08_12 == .

    // were they that status in both 2008 and 2012
bysort ncid: egen total_tag_08_12 = total(tag_08_12)


    // take maximum of tag for individual, i.e. apply tag to all observations
gen sample_08_12             = 1      if total_tag_08_12 == 2
replace sample_08_12         = 0        if total_tag_08_12 != 2
label var sample_08_12         "=1 for individuals able to vote in both 2008 or 2012"

drop tag_08_12 total_tag_08_12



* keep only people eligible to vote in 2008 or 2012
*--------------------------------------------------

keep if sample_08_12 == 1
drop sample_08_12

* Export sample size
export_sample_size "sample_0812"


*------------------------------------------------------------------------------------
* 2) drop if no voter history
*------------------------------------------------------------------------------------


bysort ncid: egen count_voted = count(ncsbe_voted)		// count() counts non-missing observations


sum count_voted
assert r(max) == 3

drop if count_voted == 0

drop count_voted

* Export
export_sample_size "sample_0812_turnout_num"
export_share "sample_0812_turnout_pct" ///
             $sample_0812_turnout_num ///
             $sample_0812

*------------------------------------------------------------------------------------
* 3) drop if don't have 3 sequential years with good geocode
*------------------------------------------------------------------------------------

* Figure out years for which geocode no-good
foreach year in 2008 2012 2016 {
    gen temp_`year' = ((accuracy_score == . & accuracy_type == .) | (accuracy_score < 0.6 & accuracy_type != 4)) if year == `year'
    bysort ncid: egen bad_geocode_`year' = max(temp_`year')
    drop temp_`year'
}

* Drop if don't get two consecutive good years (needed for regression)
gen bad_geocode = (bad_geocode_2008 == 1 | bad_geocode_2012 == 1 | bad_geocode_2016 == 1)
sum bad_geocode, meanonly
assert r(mean) < 0.1
drop if bad_geocode  == 1
drop bad_geocode*

* No longer needed geocode vars
drop accuracy_score accuracy_type

* drop anyone geo-located to a non-NC county. Should only be very, very few
*---------------------------------------------------------------------------

gen temp_state = floor(county_fips/1000) != 37
bysort ncid: egen any_bad_state = max(temp_state)
sum any_bad_state
assert r(mean) < 0.0002
drop if any_bad_state == 1
drop temp_state any_bad_state


assert latitude != .
assert longitude != .
assert census_block != .

* Export
export_sample_size "sample_geocoded_num"
export_share "sample_geocoded_pct" ///
             $sample_geocoded_num ///
             $sample_0812_turnout_num


*------------------------------------------------------------------------------------
* 4) Drop if polling place couldn't be geolocated
*------------------------------------------------------------------------------------

* Figure out years for which no polling place.
foreach year in 2008 2012 2016 {
    gen temp_`year' = (polling_latitude == .) if year == `year'
    bysort ncid: egen bad_polling_`year' = max(temp_`year')
    drop temp_`year'
}

gen no_polling = (bad_polling_2008 == 1 | bad_polling_2012 == 1 | bad_polling_2016 == 1)
sum no_polling
* Most of these are from first year. 16% missing. :(
assert r(mean) < 0.25
drop if no_polling == 1
drop no_polling bad_polling_*

* Export
export_sample_size "sample_w_polling_num"
export_share "sample_w_polling_pct" ///
             $sample_w_polling_num ///
             $sample_geocoded_num



*------------------------------------------------------------------------------------
* 5) Drop movers
*------------------------------------------------------------------------------------
* Bring in stable movers
preserve
    use 20_intermediate_files/20_movers_whose_assignments_dont_change, clear
    drop index
    gen moved_butsamepp_2008 = .
    reshape long moved_butsamepp_, i(ncid) j(year)
    rename moved_butsamepp_ moved_butsamepp
    sort ncid year
    tempfile stable_movers
    save `stable_movers', replace
restore

merge 1:1 ncid year using `stable_movers'
* Basically, all merges ok here. We dropped
* some voters for not having history (so _m==2 ok)
* and stable_movers only has movers (so _m == 1
* Below need to makes sure things line up.
drop if _m == 2
rename _m merge_movers

* make "has voter moved" variable
*----------------------------------
sort voter_index election_index
gen voter_moved = (census_block != L.census_block) if census_block != . & L.census_block != .
label var voter_moved "voter moved since last presidential election"

bysort ncid: egen voter_ever_moved = max(voter_moved)
sum voter_ever_moved, meanonly
assert r(mean) < 0.31

* Check merge from above
assert voter_ever_moved == 1 if merge_movers == 3
assert moved_butsamepp != . if voter_moved == 1
drop merge_movers

* Make refined mover vars
gen voter_ppchanging_move = (voter_moved) & (moved_butsamepp == 0)
label var voter_ppchanging_move "voter moved and wouldn't have same pp since last presidential election"

gen voter_ppsame_move = (voter_moved) & (moved_butsamepp == 1)
label var voter_ppsame_move "voter moved and wouldn't have same pp since last presidential election"

bysort ncid: egen voter_ever_ppchanging_move = max(voter_ppchanging_move)
sum voter_ever_ppchanging_move, meanonly
assert r(mean) < 0.31


***********
* Calculate share of movers who
* we can keep
***********
egen ncid_tag = tag(ncid)
count if voter_ever_moved == 1 & ncid_tag == 1
local ever_moved = r(N)
local cleaned_ever_moved: display %12.0fc `ever_moved'

count if voter_ever_ppchanging_move == 1 & ncid_tag == 1
local moved_but_no_pp_changes = `ever_moved' - r(N)
local cleaned_moved_but_no_pp_changes: display %12.0fc `moved_but_no_pp_changes'

file open myfile using $nc_electioneering/50_results_$sample_size/num_ever_moved.tex, write text replace
file write myfile "`cleaned_ever_moved'"
file close myfile

file open myfile using $nc_electioneering/50_results_$sample_size/num_moved_but_no_pp_changes.tex, write text replace
file write myfile "`cleaned_moved_but_no_pp_changes'"
file close myfile

drop ncid_tag


* Old vars that don't differentiate mover types.
* Don't ever want to accidentally use, so dropping.
drop voter_moved moved_butsamepp

label var voter_ever_moved "Voter moved at some point"
label var voter_ppchanging_move "Voter has moved in a way that would itself change polling place at some point"

sort voter_index election_index
gen drop_for_balance = L.voter_ppchanging_move == 0 & voter_ppchanging_move == 1 & year == 2016

* Save number of people dropped who could have experienced change in 2008-2012
count if drop_for_balance == 1
local to_drop = `r(N)'
count
if `r(N)' < 2000000 {
    local to_drop = `to_drop' * 10
}
local cleaned_statistic: display %12.0fc `to_drop'

file open myfile using $nc_electioneering/50_results_$sample_size/sample_drops_to_balance_movers.tex, write text replace
file write myfile "`cleaned_statistic'"
file close myfile
drop drop_for_balance


drop if voter_ever_ppchanging_move == 1
drop voter_ever_ppchanging_move

preserve
    drop if voter_ever_moved == 1
    export_sample_size "sample_wo_movers_num"
    export_share "sample_wo_movers_pct" ///
                $sample_wo_movers_num ///
                $sample_w_polling_num
restore

* rename variables
*-----------------

rename latitude voter_latitude
rename longitude voter_longitude



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
    zipsave 20_intermediate_files/50_voter_panel_long_subsampled_dta.zip, replace
}
else {
    save 20_intermediate_files/50_voter_panel_10pctsample_long_subsampled.dta, replace
}








            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **

             ** end of 05_subset_to_analysis_sample.do **
