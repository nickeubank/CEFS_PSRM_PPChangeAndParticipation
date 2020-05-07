
    ************************************************************************
    **
    **
    **        PROJECT AUTHORS:    CLINTON, EUBANK, FRESH & SHEPHERD
    **        DO FILE AUTHOR:        EUBANK
    **        DATE BEGUN:         February ?, 2018
    **
    **        PROJECT:             NC Electioneering
    **        DETAILS:				Merge early voting information in.
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








            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **



*-------------------------------------------------------------------------------
* read in and save as a .dta
*-------------------------------------------------------------------------------


* import
*-------

import delimited 00_source_data/polling_places/raw/early_voting_locations.csv, delim(",")



* drop
*-----

drop if county == "TOTAL"



* rename
*-------

rename number_of_sites 		early_vote_number_of_sites
rename evening_hours 		early_vote_evening_hours
rename saturday_hours 		early_vote_saturday_hours
rename sunday_hours 		early_vote_sunday_hours
rename total_hours			early_vote_total_hours



* label variables
*----------------

label var early_vote_number_of_sites 	"number of early voting sites (county level)"
label var early_vote_evening_hours		"evening early voting hours (county level)"
label var early_vote_saturday_hours		"saturday early voting hours (county level)"
label var early_vote_sunday_hours		"sunday early voting hours (county level)"
label var early_vote_total_hours		"total early voting hours (county level)"



* rename county
*--------------

replace county = "McDowell" if county == "Mcdowell"
replace county = county + " County"
replace county = trim(county)




* save
*-----

save 20_intermediate_files/47_early_voting_number_and_hours.dta, replace




            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
