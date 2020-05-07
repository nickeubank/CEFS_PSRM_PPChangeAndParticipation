*		Create Data file to use in R
*		Josh Clinton


* preliminaries
*--------------
clear
set more off


* set the directory
*------------------

cd $nc_electioneering



* use the data
*-------------

use 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_no_movers.dta, clear


* Helper Vars
*-------------

gen black = race != 0
gen age2 = age^2


gen blackppchange = black*pp_has_changed
gen blackprechange = black*precinct_changed
gen bothchange = pp_has_changed*precinct_changed
gen blackchange = change_in_precinct_location_km*black


sort voter_index election_index
gen lagelec = L.voted_elecday
gen lagearly = L.voted_early


drop county
drop city
drop ncid
drop voted

export delimited using "/Users/clintojd/Documents/GitHub/nc_electioneering/20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_small_forR.csv", replace
