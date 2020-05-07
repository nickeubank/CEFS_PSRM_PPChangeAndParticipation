
    ************************************************************************
    **
    **
    **        PROJECT AUTHORS:    CLINTON, EUBANK, FRESH & SHEPHERD
    **        DO FILE AUTHOR:        EUBANK
    **        DATE BEGUN:         February ?, 2018
    **
    **        PROJECT:            NC Electioneering
    **        DETAILS:
    **
    **        UPDATES:  		  Distributional Plots requested on March 28
    **
    **
    **        VERSION:             Stata 14
    **
    **
    *************************************************************************



*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------


clear
set more off

* set the directory
*------------------
cd "/Users/michael/Desktop/NC/nc_electioneering"



* use the data
*-------------

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/60_voter_panel_long_w_analysisvars_dta.zip, clear
}
else {
    use 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars.dta, clear
}



* define output directory
*------------------------

global output "${nc_electioneering}50_results_$sample_size"



*-------------------------------------------------------------------------------
* Creating counts of number of polling places by year and racial composition of counties.
*-------------------------------------------------------------------------------

** Creating Polling Place ID
egen polling_placeid = group(year precinct_id_withinyear polling_latitude polling_longitude county_fips)
** Count number of unique polling place ids
egen tag = tag(polling_placeid)

* count number of voters
gen voter=1

* id for black voter
gen black=1  if race==1
replace black=0 if race!=1

* id for democratic voter
gen democrat=1 if party==0
replace democrat=0 if party!=0

* id for female voter
gen femaleind=1 if female==1
replace femaleind=0 if female!=1


* collapse totals by county year.
collapse (mean) age black democrat femaleind (sum) voter tag, by(county_fips year)

rename tag numpolling_places

egen state_total_pp = sum(numpolling_places), by(year)


* Plots the total number of polling places each year based on sample
graph bar state_total_pp, over(year) asyvars blabel(bar, format(%9.2f)) ///
title(Number of Polling Places Statewide)


*-------------------------------------------------------------------------------
* Probability of being impacted
*-------------------------------------------------------------------------------

use 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars.dta, clear

* Generating variables to measure probability of being impacted

gen EligVoter=0
recode EligVoter (0=1) if voter_status==0 | voter_status==2

gen gender=1 if female==1
replace gender=0 if female!=1

gen age2=age^2





* Likelihood of Impact by year using Regression
areg pp_has_changed i.party i.race  age age2 if  EligVoter==1, absorb(county_fips)
areg pp_has_changed i.party i.race  age age2 if  EligVoter==1 & year==2012, absorb(county_fips)
areg pp_has_changed i.party i.race  age age2 if  EligVoter==1 & year==2016, absorb(county_fips)



* Likelihood of Impact by year using Summary Stats
egen pp_change_blk=mean(pp_has_changed) if race==1 , by(year)
egen pp_change_wht=mean(pp_has_changed) if race==0 , by(year)

egen pp_change_dem=mean(pp_has_changed) if party==0 , by(year)
egen pp_change_gop=mean(pp_has_changed) if party==1 , by(year)

* Creates a bar plot that displays the probability of experiencing a polling place change for the four groups
graph bar pp_change_blk pp_change_wht pp_change_dem pp_change_gop if year!=2008, over(year) asyvars blabel(bar, format(%9.2f)) ///
title(Probability of Polling Place Change) legend(label(1 "Blacks")label(2 "Whites")label(3 "Democrats")label(4 "Republicans"))

* Saves plot
graph export "/Users/michael/Desktop/NC/nc_electioneering/50_results_$sample_size/probabilityimpact.pdf", replace
