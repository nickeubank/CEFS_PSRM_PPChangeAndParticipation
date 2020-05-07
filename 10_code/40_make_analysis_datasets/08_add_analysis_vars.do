
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
    **        UPDATES:
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
    zipuse 20_intermediate_files/50_voter_panel_long_subsampled_wcensus_dta.zip, clear
}
else {
    use 20_intermediate_files/50_voter_panel_10pctsample_long_subsampled_wcensus.dta, clear
}





            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* generate basic analysis variables
*-------------------------------------------------------------------------------


* better precinct identifier variables
*-------------------------------------

foreach v in precinct_id precinct_name {

   replace `v' = "" if `v' == "nan"

}

egen precinct_id_withinyear = group( year county_fips precinct_id precinct_name)
label var precinct_id_withinyear "unique precinct id (note not comparable across years!)"



* check the new precinct identifier
*----------------------------------

bysort year: egen temp_min = min(precinct_id_withinyear)
bysort year: egen temp_max = max(precinct_id_withinyear)
gen temp_dif = temp_max - temp_min

foreach year in 2008 2012 2016 {

   sum temp_dif if year == `year'
   assert r(mean) > 2100 & r(mean) < 2600

}

drop temp_*
drop precinct_id precinct_name






    /*

        Make "has polling place changed" var.
        Around North Carolina, 1 degree latitude (35 to 36 @ 78) is about 111 km
        1 degree longitude (78 to 79 @ 35.5) is about 90km
        good enough for first-order approximation of "no change"

    */


* use wikipedia information to assess polling place location amount change
*-------------------------------------------------------------------------

sort voter_index election_index
gen change_in_precinct_location_km = sqrt((111 * (polling_latitude - L.polling_latitude))^2 + ///
                                          (90 * (polling_longitude - L.polling_longitude))^2)
sum change_in_precinct_location_km, d
label var  change_in_precinct_location_km "approximate change in polling place location since last presidential elec"



* more than 100 meters is a change (wikipedia says in some states)
*-----------------------------------------------------------------

gen pp_has_changed = change_in_precinct_location_km > 0.1 ///
                     if change_in_precinct_location_km !=.
label var pp_has_changed "polling place moved by at least 100m but voter didn't move since last election"

* Few checks to make sure missing for anyone with some missing data.
assert pp_has_changed == . if L.voter_census_block == .
assert pp_has_changed == . if voter_census_block == .
assert pp_has_changed == . if polling_latitude == .
assert pp_has_changed == . if L.polling_latitude == .



* Check to make sure travel times are fixed
* (See issue #80)
*----------------------------------
sum D.minutes_driving if  pp_has_changed == 0 & voter_ppchanging_move == 0 & voter_ppsame_move == 0, d
assert r(min) > -4 & r(max) < 4

assert D.minutes_driving == 0 if change_in_precinct_location_km == 0 & ///
        D.minutes_driving != . & voter_ppchanging_move == 0 & voter_ppsame_move == 0


            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* Make master version of panel vars (like race, gender, etc.).
* Very rarely but occassionally they change...
* Also move hispanic into main race var (Issue #100)
*-------------------------------------------------------------------------------
replace race = 7 if hispanic == 0 & race == 0
assert race > 0 & race != 0 if hispanic == 0
tab race hispanic
label define race_2016 7"Hispanic", modify
bysort ncid: egen temp_mode = mode(race), maxmode
local race_labels: value label race
replace race = temp_mode
label values race `race_labels'

count if race == 0 & hispanic == 0
local off = r(N)
count
assert `off' / r(N) < 0.0001
drop temp_mode
drop hispanic



            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* Make voting variables
*-------------------------------------------------------------------------------

rename ncsbe_voted temp
decode temp, gen(ncsbe_voted)
drop temp

gen voted_elecday = (ncsbe_voted == "IN-PERSON" | ncsbe_voted == "CURBSIDE" | ncsbe_voted == "ABSENTEE CURBSIDE")
label var voted_elecday         "voted election day in current presidential election"

gen voted_early = (ncsbe_voted == "ABSENTEE ONESTOP")
label var voted_early           "voted early in current presidential election"

gen voted_mailin = (ncsbe_voted == "ABSENTEE BY MAIL" )
label var voted_mailin          "voted by mailing ballot in current presidential election"

gen voted_weird = (ncsbe_voted == "PROVISIONAL" | ncsbe_voted == "TRANSFER" | ncsbe_voted == "ABSENTEE")
label var voted_weird     "cast provisional, transfer, or unspecified absentee ballot"

gen voted_ANY = (ncsbe_voted != "DID NOT VOTE")
gen test = voted_elecday + voted_early + voted_mailin + voted_weird
assert test == 1 if voted_ANY == 1
assert test == 0 if voted_ANY == 0
label var voted_ANY "Voted"

rename ncsbe_voted ncsbe_voted_categorical
label var ncsbe_voted "How person voted (NCSBE)"

rename ts_voted ts_voted_categorical
label var ts_voted "How person voted (TargetSmart)"


gen counter = 1
sort voter_index election_index

gen last_precinct = L.precinct_id_withinyear

bysort precinct_id_withinyear: egen precinct_size = sum(counter)
bysort last_precinct: egen last_precinct_size = sum(counter)
bysort precinct_id_withinyear last_precinct: egen total_in_both = sum(counter)

#delimit ;
gen precinct_changed = (
                        ((total_in_both / last_precinct_size) < 0.75) |
                        ((total_in_both / precinct_size) < 0.75)
                     );

#delimit cr

drop counter last_precinct_size total_in_both

label var precinct_changed "Voter did not move but precinct changed composition. See issue #10"

label var precinct_size "Number or registered voters in precinct"

* Some precinct sizes seem implausible, potentially due to
* imprecise geocodes? Let's limit to above first percentile.
sum precinct_size, d
replace precinct_size = . if precinct_size < r(p1)



**    **    **    **    **    **    **    **    **    **    **    **    **
**    **    **    **    **    **    **    **    **    **    **    **    **
**    **    **    **    **    **    **    **    **    **    **    **    **


*-------------------------------------------------------------------------------
* Clean up some age instability issues. Looked all the way back to voter rolls
* and problems come from there.
*
* Looks like occassionally a new person (child?) gets parent's NCID, and
* as a result age *drops*, which is crazy town. See Issue #99.
*-------------------------------------------------------------------------------

gen problem = age > 125
bysort ncid: egen has_problem = max(problem)
drop if has_problem == 1
drop problem has_problem

* Make a panel age var
gen temp = age if year == 2008
bysort ncid: egen age_in_2008 = min(temp)
label var age_in_2008 "Voter Age in 2008"
drop temp

bysort ncid: egen min_age = min(age)


* note because date of election day moves year to year, can actually have a
* few people who age 5 years between elections. Checked and seem fine.
gen age_problem_08 = age > min_age & year == 2008
gen age_problem_12 = age > (age_in_2008 + 5) & year == 2012
gen age_problem_16 = age > (age_in_2008 + 9) & year == 2016


bysort ncid: egen has_problem_08 = max(age_problem_08)
bysort ncid: egen has_problem_12 = max(age_problem_12)
bysort ncid: egen has_problem_16 = max(age_problem_16)


count if has_problem_08 == 1 | has_problem_12 == 1 | has_problem_16 == 1
local probs = r(N)
count
assert `probs' / r(N) < 0.006
drop if has_problem_08 == 1 | has_problem_12 == 1 | has_problem_16 == 1
drop age_problem* min_age





			**    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **


*-------------------------------------------------------------------------------
* merge early voting location number and hours open
*-------------------------------------------------------------------------------

* merge
*------

merge m:1 county year using 20_intermediate_files/47_early_voting_number_and_hours.dta

assert _merge != 2
drop _merge






			**    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **


*-------------------------------------------------------------------------------
* rename and label variables
*-------------------------------------------------------------------------------


* rename and label some variables
*--------------------------------

rename minutes_driving pp_minutes_driving
label var pp_minutes_driving "minutes to drive to polling place (google maps, 10am, election day 2018)"


* label remaning variables
*-------------------------

label var race                     "voter's race, categorical"
label var voter_latitude         "voter address, latitude"
label var voter_longitude         "voter address, longitude"

label var polling_latitude         "polling place address, latitude"
label var polling_longitude        "polling place address, longitude"
label var county                "numeric county code"

label var county_fips            "county fips code"
label var age                    "voter's age"
label var zip_code                "voter's zip code"

label var year                    "year"
label var city                    "voter's city"
label var female                "voter's gender (=1 for female)"

label var voter_census_block    "voter's census block id"
label var voter_status            "voter is active, inactive, denied or temporary"

label var party                    "voter's party id"



            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* save the data
*-------------------------------------------------------------------------------

* save the data with movers
*--------------

cd $nc_electioneering
if "$sample_size" == "full" {
    zipsave 20_intermediate_files/60_voter_panel_long_w_analysisvars_w_movers_dta.zip, replace
}
else {
    save 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_w_movers.dta, replace
}



* save the data without movers
*--------------

drop if  voter_ever_moved == 1
drop voter_ever_moved  voter_ppchanging_move voter_ppsame_move

if "$sample_size" == "full" {
    zipsave 20_intermediate_files/60_voter_panel_long_w_analysisvars_no_movers_dta.zip, replace
}
else {
    save 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_no_movers.dta, replace
}




            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **

             ** end of 20_add_analysis_vars.do **
