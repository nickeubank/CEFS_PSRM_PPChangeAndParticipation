
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
    **        UPDATES:  		  Paper Figure Outputs.
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
						native_am_x_year asian_x_year multi_race_x_year"
						;


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



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	FIGURE 2 (Plot a):  	Distribution of polling place distance moves
*-------------------------------------------------------------------------------


* plot
*-----

	#delimit ;

		twoway

			( kdensity change_in_precinct_location_km   	if  pp_has_changed == 1
				,  lcolor(black) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Polling Place Location, Kilometers",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_PPMoveDistance.pdf, replace




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	FIGURE 2 (Plot b): 	Distribution of drive time changes
*-------------------------------------------------------------------------------


* plot
*-----

	#delimit ;

		twoway

			( kdensity pp_minutes_driving_change   	if  pp_has_changed == 1
				, xline(0, lcolor(gs10)) lcolor(black) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Drive Time to Polling Place, Minutes",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_DriveTime.pdf, replace









			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* 	FIGURE 3: 	Bar charts of voting
*
*		Description: Plots a, b, and c for Election Day, Early and Overall Turnout
*-------------------------------------------------------------------------------


* polling place change and total vote
*------------------------------------

#delimit ;


		graph

			bar (mean) voted_ANY  if year > 2008

			,

			over(pp_has_changed)
			asyvar
			over(year)

			bar(1, color(gs10)) bar(2, color(gs4))

			xsize(4)
			ysize(5)
			exclude0
			yscale(noline)
			ylab(.2(.1).85,
				angle(hori) labsize(medsmall) nogrid  )
			ytitle("% Voted",
				color(black) size(medium)  )

			title("", color(black) size(medsmall) pos(11) )
			graphregion( fcolor(white) lcolor(white) )
			plotregion( fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

			legend(order(
				1 "No PP Change"
				2 "PP Change"
				)
			cols(2)
            position(6)
			region( color(none) )
			size(medsmall)
				)


		;

		# delimit cr



		* export plot
		*------------

		cd "${output}"
		graph export "Plot_Bar_Vote_any.pdf", replace





* polling place change and early voting
*--------------------------------------

#delimit ;


		graph

			 bar (mean) voted_early  if year > 2008

			,

			over(pp_has_changed)
			asyvar
			over(year)

			bar(1, color(gs10)) bar(2, color(gs4))

			xsize(4)
			ysize(5)
			exclude0
			yscale(noline)
			ylab(.2(.1).85,
				angle(hori) labsize(medsmall) nogrid  )
			ytitle("% Voted Early",
				color(black) size(medium)  )

			title("", color(black) size(medsmall) pos(11) )
			graphregion( fcolor(white) lcolor(white) )
			plotregion( fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

			legend(order(
				1 "No PP Change"
				2 "PP Change"
				)
			cols(2)
			region( color(none) )
			size(medsmall)
            position(6)
				)


		;

		# delimit cr



		* export plot
		*------------

		cd "${output}"
		graph export "Plot_Bar_Vote_early.pdf", replace






* polling place change and election day voting
*---------------------------------------------

#delimit ;


		graph

			 bar (mean) voted_elecday  if year > 2008

			,

			over(pp_has_changed)
			asyvar
			over(year)

			bar(1, color(gs10)) bar(2, color(gs4))

			xsize(4)
			ysize(5)
			exclude0
			yscale(noline)
			ylab(.2(.1).85,
				angle(hori) labsize(medsmall) nogrid  )
			ytitle("% Voted on Election Day",
				color(black) size(medium)  )

			title("", color(black) size(medsmall) pos(11) )
			graphregion( fcolor(white) lcolor(white) )
			plotregion( fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

			legend(order(
				1 "No PP Change"
				2 "PP Change"
				)
			cols(2)
			region( color(none) )
			size(medsmall)
            position(6)
				)


		;

		# delimit cr



		* export plot
		*------------

		cd "${output}"
		graph export "Plot_Bar_Vote_elecday.pdf", replace





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	FIGURE 4: 	Scatter plot of binned drive time
*
*			Description: With local polynomial fits
*-------------------------------------------------------------------------------


* preserve and keep
*------------------

preserve
keep if pp_has_changed == 1



* bins
*-----

capture drop drive_time_bin
gen drive_time_bin = .
label var drive_time_bin "bins for pp_minutes_driving_change"


gen abs_change = abs(pp_minutes_driving_change)
sum abs_change, d

local upper	 		= -int(r(p99))
local end_value 	= int(r(p99))
local increment		= 2
local range 		= "(pp_minutes_driving_change > `upper' & pp_minutes_driving_change < `end_value')"


while `upper' <= `end_value'  {

	local lower = `upper' - `increment'
	local midvalue = `upper' - (`increment' / 2)

	display "Upper: `upper'"
	display "Lower: `lower'"
	display "MidValue: `midvalue'"

	replace drive_time_bin = `midvalue'  		if pp_minutes_driving_change >= `lower' 	& pp_minutes_driving_change < `upper'
	local upper = `upper' + `increment'


}




* tag bin
*--------

capture drop tag_bin
egen tag_bin = tag(drive_time_bin)
label var tag_bin "tag for 1 observation in each drive time bin"



* loop to plot
*-------------

local outcomes = "voted_elecday  voted_early"


foreach x of local outcomes {

	* labels
	*-------

		if "`x'" == "voted_elecday"{
			local out = "% Voted on Election Day"
			local out2 = "elecday"
			local scale = ".25(.025).3"
		}
		else if "`x'" == "voted_early"{
			local out = "% Voted Early"
			local out2 = "early"
			local scale = ".45(.025).55"
		}


	* averages within bins
	*---------------------

	capture drop `x'_b
	bysort drive_time_bin: egen `x'_b = mean(`x')


	* count observations within bins
	*-------------------------------

	capture drop count_bin
	bysort drive_time_bin: egen count_bin = count(`x')



	* plot
	*-----

	#delimit ;

		twoway

			( scatter `x'_b 	drive_time_bin   	[aweight=count_bin]
						if tag_bin == 1 & `range'
				, msize(large) mcolor(gs4) msymbol(circle_hollow) )

			//( lfitci `x' 		pp_minutes_driving_change					if (tag_bin == 1 | tag_bin != 1) & `range'
			  //,  clwidth(medium) clcolor(black) alcolor(gs8) alwidth(medthick)
				//alpattern(line) fcolor(none) xline(0, lcolor(gs8)) )

			( lpolyci `x' 		pp_minutes_driving_change
						if (tag_bin == 1 | tag_bin != 1)  & `range'
						//& (pp_minutes_driving_change >= -10 & pp_minutes_driving_change <= 10)
			  ,  clwidth(medium) clpattern(dash) clcolor(black) alcolor(black) alwidth(medthick)
			     alpattern(dot) fcolor(none) deg(1) bwidth(3)  xline(0, lcolor(gs8)) )

			,

			ylabel( `scale',
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("`out'",
				angle(hori)	color(black) size(medium) )

			xlabel(  -10(5)10,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Drive Time to Polling Place, Minutes",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_DriveTime_`out2'.pdf, replace


	* drop
	*-----

	drop `x'_b
	drop count_bin


}



* restore
*--------

restore




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	FIGURE 5:	Early voting availability
*
*			Description: Total hours, Number of Locations
*-------------------------------------------------------------------------------


* county group
*-------------

capture drop county_group
egen county_group = group(county_fips)
label var county_group "sequential county numeric"



* county mean early voting
*-------------------------

capture drop vote_early_ct_mean
bysort county_group year: egen vote_early_ct_mean = mean(voted_early)
label var vote_early_ct_mean "proportion of the county voters voting early, by year"

capture drop tag_ct_year
egen tag_ct_year = tag(county year)
label var tag_ct_year "tag =1 for each unique county year pair"



* registered voters by county
*----------------------------

capture drop total_reg_voters_ct
bysort county_group year: egen total_reg_voters_ct = count(ncid)
label var total_reg_voters_ct "total registered voters by county by year"




* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_early"
global dv2					= "voted_elecday"
global dv3					= "voted_ANY"
global number_of_outcomes	= 2

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed"

global controls				= "black_x_year hispanic_x_year unknown_x_year other_x_year native_am_x_year asian_x_year multi_race_x_year"
global controlsfull			= "age age2 female black hispanic unknown other native_am asian multi_race census_hh_med_income voted_last party_rep party_una party_lib"

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster1				= "ncid"
global cluster2				= "county_fips"



* new variables to store the regression output
*---------------------------------------------

capture drop beta1
capture drop beta2
capture drop beta3
capture drop se1
capture drop se2
capture drop se3

gen beta1 = .
gen se1 = .

gen beta2 = .
gen se2 = .

gen beta3 = .
gen se3 = .



* estimate each beta
*-------------------

local years = "2012 2016"

foreach y of local years {

	forvalues x = 1/100 {

		reg ${dv1} ${iv1}  ${controlsfull} 	if  county_group == `x' & year == `y' ///
					, vce(robust)

		display "YEAR: `y'"
		display "County: `x'"
		replace beta1 	= _b[pp_has_changed]  	if county_group == `x' & year == `y'
		replace se1 		= _se[pp_has_changed]	if county_group == `x' & year == `y'


		reg ${dv2} ${iv1}  ${controlsfull} 	if  county_group == `x' & year == `y' ///
					, vce(robust)

		replace beta2 	= _b[pp_has_changed]  	if county_group == `x' & year == `y'
		replace se2 	= _se[pp_has_changed]	if county_group == `x' & year == `y'


		reg ${dv3} ${iv1}  ${controlsfull} 	if  county_group == `x' & year == `y' ///
					, vce(robust)

		replace beta3 	= _b[pp_has_changed]  	if county_group == `x' & year == `y'
		replace se3 	= _se[pp_has_changed]	if county_group == `x' & year == `y'

	}
}






* plot
*-----

	#delimit ;

		twoway

			( scatter beta1 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Locations",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyLocations_EarlyVote.pdf, replace




* plot
*-----

	#delimit ;

		twoway

			( scatter beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Total Early Voting Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyHours_EarlyVote.pdf, replace



* plot
*-----

	#delimit ;

		twoway

			( scatter beta2 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta2 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta2 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta2 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Elec Day Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Locations",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyLocations_ElecVote.pdf, replace




* plot
*-----

	#delimit ;

		twoway

			( scatter beta2 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta2 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta2 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta2 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Elec Day Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Total Early Voting Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyHours_ElecVote.pdf, replace




* plot
*-----

	#delimit ;

		twoway

			( scatter beta3 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta3 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta3 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta3 early_vote_number_of_sites
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Total Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Locations",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyLocations_TotalVote.pdf, replace




* plot
*-----

	#delimit ;

		twoway

			( scatter beta3 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta3 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta3 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta3 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Total Early Voting Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyHours_TotalVote.pdf, replace




* plot LEGEND
*------------

	#delimit ;

		twoway

			( scatter beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) )

			( lfit beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black)   )

			( scatter beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) )

			( lfit beta1 early_vote_total_hours
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(dash) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Registered Voters per Early Voting Hour",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( order(
				1 "2012"
				3 "2016"
				2 "2012 Linear Fit"
				4 "2016 Linear Fit"
				)
			cols(4)
			region( color(none) )
			size(medsmall)
				)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyHours_Legend.pdf, replace



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	FIGURE 6: 	Binned scatter plot of age
*
*			Description: Difference in how ages vote by polling place change
*-------------------------------------------------------------------------------


* preserve
*---------

preserve

keep if age >= 22 & age < 100
keep if year > 2008



* bins
*-----

capture drop age_bin
gen age_bin = .
label var age_bin "bins for age"

local upper	 		= 22
local end_value 	= 100
local increment		= 5
local range 		= "(age > `upper' & age < `end_value')"


while `upper' <= `end_value'  {

	local lower 		= `upper' - `increment'
	local midvalue 		= `upper' - (`increment' / 2)

	display "Upper: `upper'"
	display "Lower: `lower'"
	display "MidValue: `midvalue'"

	replace age_bin 	= `midvalue'  		if age >= `lower' 	& age < `upper'
	local upper 		= `upper' + `increment'


}




* tag bin
*--------

capture drop tag_bin
egen tag_bin = tag(pp_has_changed age_bin)
label var tag_bin "tag for 1 observation in each age bin by pp_has_changed"



* tag age
*--------

capture drop tag_age
egen tag_age = tag(age)




* loop to plot
*-------------

local outcomes = "voted_elecday  voted_early  voted_ANY"


foreach x of local outcomes {

	* labels
	*-------

		if "`x'" == "voted_elecday"{
			local out = "Difference in % Voted on Election Day"
			local out2 = "elecday"
		}
		else if "`x'" == "voted_early"{
			local out = "Difference in % Voted Early"
			local out2 = "early"
		}
		else if "`x'" == "voted_ANY"{
			local out = "Difference in % Turnout"
			local out2 = "any"
		}


	* averages within bins
	*---------------------

	capture drop `x'_b_ppchanged
	capture drop `x'_b_noppchanged
	capture drop test

	bysort age_bin: egen test = mean(`x')	if pp_has_changed == 1
	bysort age_bin: egen `x'_b_ppchanged = max(test)
	drop test

	bysort age_bin: egen test = mean(`x')	if pp_has_changed == 0
	bysort age_bin: egen `x'_b_noppchanged = max(test)
	drop test



	* difference in averages within a bin
	*------------------------------------

	capture drop `x'_bin_difference
	gen `x'_bin_difference = `x'_b_ppchanged - `x'_b_noppchanged



	* differences in outcomes by age
	*-------------------------------

	capture drop `x'_nochange
	capture drop `x'_change
	capture drop `x'_difference
	capture drop test

	bysort age: egen  test 	= mean(`x')		if pp_has_changed == 1
	bysort age: egen `x'_change = max(test)
	drop test

	bysort age: egen  test 	= mean(`x')		if pp_has_changed == 0
	bysort age: egen `x'_nochange = max(test)
	drop test

	gen `x'_difference = `x'_change - `x'_nochange



	* count observations within bins
	*-------------------------------

	capture drop count_bin
	bysort age_bin: egen count_bin = count(`x')



	* plot
	*-----

	#delimit ;

		twoway

			( scatter `x'_bin_difference 	age_bin   	[aweight=count_bin]
					if tag_bin == 1 & `range'
				, msize(large) mcolor(gs4) msymbol(circle_hollow) )


			( lpolyci `x'_difference 	age
					if (tag_age == 1) & `range' & age >= 22
			  ,  clwidth(medium) clpattern(dash) clcolor(black) alcolor(black) alwidth(medthick)
			     alpattern(dot) fcolor(none) deg(1) bwidth(3)  yline(0, lcolor(gs8) lwidth(medthick)) )

			,

			ylabel( -.1(.05).1,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("`out'",
				angle(hori)	color(black) size(medium) )

			xlabel( 20(20)100 ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Voter Age",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_Age_`out2'_ppchange.pdf, replace




	* drop
	*-----

	drop `x'_b_noppchanged
	drop `x'_b_ppchanged
	drop count_bin


}



* restore
*--------

restore





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



						** APPENDIX FIGURES **


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**




*-------------------------------------------------------------------------------
* 	APPENDIX PLOT
*-------------------------------------------------------------------------------




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* 	APPENDIX PLOT F.1-F.3: 		Point estimates of main effect by county
*
*			Description: County specific panel effects for each outcome
*-------------------------------------------------------------------------------


** ONLY RE-RUN THIS COMMENTED PART IF THE DATASET HAS CHANGED (takes forever to run)


* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_ANY"
global dv2					= "voted_early"
global dv3					= "voted_elecday"

global iv1					= "pp_has_changed"

global controls				= "black_x_year hispanic_x_year unknown_x_year other_x_year native_am_x_year asian_x_year multi_race_x_year"
global cluster1				= "precinct_group"


* temp file
*----------

tempname memhold
tempfile results
postfile `memhold' 	beta_any se_any  beta_early se_early  beta_elec se_elec ///
					str10 county_name county_num   using `results'



* county group
*-------------

capture drop county_group
egen county_group = group(county_name)




* estimate each beta for the panel
*---------------------------------

	forvalues x = 1/100 {

		levelsof county_name 	if county_group == `x', local(county_name) clean


		// panel: any
		xi: areg ${dv1} ${iv1}  ${controls} i.year		if county_group == `x'  ///
					, vce(cl ${cluster1}) absorb(ncid)

			post `memhold' (_b[${iv1}]) (_se[${iv1}]) (.) (.) (.) (.)  ("`county_name'") (`x')


		// panel: early
		xi: areg ${dv2} ${iv1}  ${controls} i.year		if county_group == `x'  ///
					, vce(cl ${cluster1}) absorb(ncid)

			post `memhold' (.) (.) (_b[${iv1}]) (_se[${iv1}]) (.) (.)  ("`county_name'") (`x')


		// panel: elec day
		xi: areg ${dv3} ${iv1}  ${controls} i.year		if county_group == `x'  ///
					, vce(cl ${cluster1}) absorb(ncid)

			post `memhold' (.) (.) (.) (.) (_b[${iv1}]) (_se[${iv1}])  ("`county_name'") (`x')


	}






* post close
*-----------

preserve

postclose `memhold'
use `results', clear

cd $nc_electioneering




* save so that can use later
*---------------------------


if "$sample_size" == "full" {
    zipsave 20_intermediate_files/70_individual_county_regression_coefficients_dta_ppchange.zip, replace
}
else {
    save 20_intermediate_files/70_individual_county_regression_coefficients_ppchange_10percent.dta, replace
}

capture preserve



* use
*----

cd $nc_electioneering

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/70_individual_county_regression_coefficients_dta_ppchange.zip, clear
}
else {
    use 20_intermediate_files/70_individual_county_regression_coefficients_ppchange_10percent.dta, clear
}



* First do multiple test corrections
* -----------------------------------

* hypotheses be sorted in order of decreasing significance
* M  = num tests
* r = test index when sorted by significance
* q = 0.05 (FDR)
* Let c be the largest r for which p_r < qr/M
* Let c be the largest r for which pr < qr/M.



foreach outcome in elec any  early {

    gen `outcome' = beta_`outcome' != .
    gen tvalue = beta_`outcome' / se_`outcome' if `outcome' == 1 & se_`outcome' != 0
    gen pvalue = 2*ttail(1000, abs(tvalue)) // Don't just have z-stat, so pick df that converges to normal. Samples always huge.
    sort pvalue
    gen r = _n if `outcome' == 1 & se_`outcome' != 0
    egen num_tests = max(r)
    sum num_tests
    local M = r(mean)
    assert `M' <= 100
    assert `M' > 75


    * BKY 2-pass correction
    * ---------

    * Pass 1
    local q = 0.05
    local q_prime = `q' / (1 + `q')

    gen test_stat = `q_prime' * r / `M'
    gen sig = pvalue < test_stat  if `outcome' == 1 & se_`outcome' != 0

    sum sig
    if r(max) == 0{
        gen temp = .
        gen max_reject = 0
    }
    else {
        egen temp = max(r) if sig == 1
        egen max_reject = max(temp)
    }
    gen reject_null_BKY_pass1 = r <= max_reject if r != .


    egen rejections = sum(reject_null_BKY_pass1)
    sum rejections
    local c = r(mean)
    drop max_reject temp sig test_stat reject_null_BKY_pass1 rejections

    if `c' == 0 {
        gen reject_null_BKY_pass2_`outcome' = 0 if pvalue != . & se_`outcome' != .
    }
    else {
        * Pass 2
        local m_hat = `M' - `c'
        gen test_stat = `q' * r / `m_hat'
        gen sig = pvalue < test_stat  if test_stat != . & pvalue != .

        egen temp = max(r) if sig == 1
        egen max_reject = max(temp)

        gen reject_null_BKY_pass2_`outcome' = r <= max_reject
        drop max_reject temp sig test_stat
    }

    drop num_tests tvalue r pvalue
}


* generate ci
*------------

// sort beta
gen sortid = _n

local ends = "any early elec"

foreach x of local ends {

	gen cihi_`x' = beta_`x' + (1.96 * se_`x')
	gen cilo_`x' = beta_`x' - (1.96 * se_`x')

}


encode county_name, gen(temp)
drop county_name
rename temp county_name



* resort the county number order
*-------------------------------

gen county_num2 = 101 - county_num






* loop to make the plots
*-----------------------


local ends = "any elec early"


foreach x of local ends {

    if "`x'" == "any" {
        local range = "-.2 0.2"
        local labels = "-.2(0.1)0.2"
    }
    else {
        local range = "-.2 0.2"
        local labels = "-.2(0.1)0.2"
    }




	* plot: ANY vote, part 1 (counties 100-50)
	*-----------------------------------------

	#delimit ;

	twoway

		( rcap cihi_`x' cilo_`x' county_num if se_`x' != .  & county_num >= 50 & county_num <= 100 &
            reject_null_BKY_pass2_`x' == 0
			, lwidth(medthin) color(black) msize(vtiny) hor
			  xline(0, lwidth(medthin) lcolor(gs9) lpattern(dash) )
			)
		( scatter county_num beta_`x' if se_`x' != .  & county_num >= 50 & county_num <= 100 &
            reject_null_BKY_pass2_`x' == 0
			, color(black)  msize(medsmall)
			)
        ( rcap cihi_`x' cilo_`x' county_num if se_`x' != .  & county_num >= 50 & county_num <= 100 &
            reject_null_BKY_pass2_`x' == 1 , lwidth(medthin) color(red) msize(vtiny) hor
              xline(0, lwidth(medthin) lcolor(gs9) lpattern(dash) )
            )
		( scatter county_num beta_`x' if se_`x' != .  & county_num >= 50 & county_num <= 100 &
            reject_null_BKY_pass2_`x' == 1
			, color(red)  msize(medium) msymbol(D)
			)

			,

		ylabel( 	100 "Alamance"
					99 "Alexander"
					98 "Alleghany"
					97 "Anson"
					96 "Ashe"
					95 "Avery"
					94 "Beaufort"
					93 "Bertie"
					92 "Bladen"
					91 "Brunswick"
					90 "Buncombe"
					89 "Burke"
					88 "Cabarrus"
					87 "Caldwell"
					86 "Camden"
					85 "Carteret"
					84 "Caswell"
					83 "Catawba"
					82 "Chatham"
					81 "Cherokee"
					80 "Chowan"
					79 "Clay"
					78 "Cleveland"
					77 "Columbus"
					76 "Craven"
					75 "Cumberland"
					74 "Currituck"
					73 "Dare"
					72 "Davidson"
					71 "Davie"
					70 "Duplin"
					69 "Durham"
					68 "Edgecombe"
					67 "Forsyth"
					66 "Franklin"
					65 "Gaston"
					64 "Gates"
					63 "Graham"
					62 "Granville"
					61 "Greene"
					60 "Guilford"
					59 "Halifax"
					58 "Harnett"
					57 "Haywood"
					56 "Henderson"
					55 "Hertford"
					54 "Hoke"
					53 "Hyde"
					52 "Iredell"
					51 "Jackson"
					50 "Johnston"

				,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle( " ",
			angle(hori)	color(black) size(vsmall) )

		xlabel( `labels',
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle("Estimate of the Effect of a Polling Place Change",
			color(none) size(small) )

		xsize(4)
		ysize(7)
		xscale(noline range(`range'))
		yscale(noline)
		graphregion(fcolor(white) lcolor(white) )
		plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
		title("  ",
			color(black) size(medsmall) pos(5) )
		subtitle("",
			color(black) justification(center))
		legend(off  )
		;

		#delimit cr




	* output
	*-------

	capture cd "${output}"
	capture graph export Plot_County_Coefficients_`x'vote1.pdf, replace




	* plot: ANY vote by county (counties 0-40)
	*-----------------------------------------


	#delimit ;


	twoway

    ( rcap cihi_`x' cilo_`x' county_num if se_`x' != .  & county_num <= 49 &
        reject_null_BKY_pass2_`x' == 0
        , lwidth(medthin) color(black) msize(vtiny) hor
          xline(0, lwidth(medthin) lcolor(gs9) lpattern(dash) )
        )
    ( scatter county_num beta_`x' if se_`x' != .  & county_num <= 49 &
        reject_null_BKY_pass2_`x' == 0
        , color(black)  msize(medsmall)
        )
    ( rcap cihi_`x' cilo_`x' county_num if se_`x' != .  & county_num <= 49 &
        reject_null_BKY_pass2_`x' == 1 , lwidth(medthin) color(red) msize(vtiny) hor
          xline(0, lwidth(medthin) lcolor(gs9) lpattern(dash) )
        )
    ( scatter county_num beta_`x' if se_`x' != .  & county_num <= 49 &
        reject_null_BKY_pass2_`x' == 1
        , color(red)  msize(medium) msymbol(D)
        )

			,

		ylabel( 	49 "Jones"
					48 "Lee"
					47 "Lenoir"
					46 "Lincoln"
					45 "Macon"
					44 "Madison"
					43 "Martin"
					42 "McDowell"
					41 "Mecklenburg"
					40 "Mitchell"
					39 "Montgomery"
					38 "Moore"
					37 "Nash"
					36 "New Hanover"
					35 "Northampton"
					34 "Onslow"
					33 "Orange"
					32 "Pamlico"
					31 "Pasquotank"
					30 "Pender"
					29 "Perquimans"
					28 "Person"
					27 "Pitt"
					26 "Polk"
					25 "Randolph"
					24 "Richmond"
					23 "Robeson"
					22 "Rockingham"
					21 "Rowan"
					20 "Rutherford"
					19 "Sampson"
					18 "Scotland"
					17 "Stanly"
					16 "Stokes"
					15 "Surry"
					14 "Swain"
					13 "Translyvania"
					12 "Tyrrell"
					11 "Union"
					10 "Vance"
					9 "Wake"
					8 "Warren"
					7 "Washington"
					6 "Watauga"
					5 "Wayne"
					4 "Wilkes"
					3 "Wilson"
					2 "Yadkin"
					1 "Yancey"
					0 " "

				,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle( " ",
			angle(hori)	color(black) size(vsmall) )

		xlabel( `labels' ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle("Estimate of the Effect of a Polling Place Change",
			color(none) size(small) )

		xsize(4)
		ysize(7)
		xscale(noline  range(`range'))
		yscale(noline)
		graphregion(fcolor(white) lcolor(white) )
		plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
		title("  ",
			color(black) size(medsmall) pos(5) )
		subtitle("",
			color(black) justification(center))
		legend(off  )
		;

		#delimit cr


	* output
	*-------

	capture cd "${output}"
	capture graph export Plot_County_Coefficients_`x'vote2.pdf, replace



	* normal
	*-------

    pnorm beta_`x' if se_`x' != 0, ///
        title("Point Estimates Plotted Against Normal Distribution, `x'") ///
        mlabel(county_name ) mlabsize(vsmall) mlabangle(-45) mlabposition(4)
    graph export nc1_county_point_estimate_pnorm_`x'.pdf, replace

        gen results = 1
        set obs 100000
        replace results = 0 if results == .
        sum beta_`x' if se_`x' != 0
        local min = r(min)
        if `min' > -0.2 {
            local min = -0.2
        }

        local max = r(max)
        if `max' > 0.2 {
            local max = 0.2
        }

        if "`x'" == "elec" {
            gen norm = rnormal(r(mean) + 0.005, r(sd)*0.6 )
        }
        if "`x'" == "any" {
            gen norm = rnormal(r(mean) , r(sd)*0.5 )
        }
        if "`x'" == "early" {
            gen norm = rnormal(r(mean) , r(sd)*0.7 )
        }

        drop if norm < `min' | norm > `max'




        	// plot of distribution
        	//---------------------
        	# delimit ;


            twoway

        		(kdensity beta_`x'
        			if se_`x' != 0 & results == 1,
                    lcolor(black) xline(0, lwidth(medthin) lcolor(gs9)) )

                (kdensity norm
        			if results == 0 ,
					lcolor(gs6) lpattern(dash) )
        		,
                title("")
                subtitle("")

        		ylabel( ,
            			tlength(0) angle(hori) nogrid labsize(small) )
            	ytitle( "Density",
            			angle(hori)	color(black) size(vsmall) )

            	xlabel(  ,
            			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
            	xtitle("Estimate of Effect of Polling Place Change",
            			color(black) size(small) )

        		yscale(noline)
        		xscale(noline)
            	graphregion(fcolor(white) lcolor(white) )
            	plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
                legend(
        			position(6)
        			cols(2)
        			label(1 "County-Estimates") label(2 "Normal PDF")
					region( color(none) )
					size(medium)
        			)
        		;

        	#delimit cr


        	// export graph
        	//-------------
            capture cd "$nc_electioneering/50_results_$sample_size"
            graph export nc1_county_point_estimate_density_`x'.pdf, replace

        	// drop
        	//-----
            drop if results == 0
            drop norm results



}

* restore
*--------

restore





*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE I.1:  	Distribution of polling place distance moves
*
*		Description: By year
*-------------------------------------------------------------------------------



* plot
*-----

	#delimit ;

		twoway

			( kdensity change_in_precinct_location_km   	if  pp_has_changed == 1 & year == 2012
				,  lcolor(black) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Polling Place Location, Kilometers",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_PPMoveDistance_2012.pdf, replace





* plot
*-----

	#delimit ;

		twoway

			( kdensity change_in_precinct_location_km   	if  pp_has_changed == 1 & year == 2016
				,  lcolor(gs4) lpattern(dash))

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Polling Place Location, Kilometers",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_PPMoveDistance_2016.pdf, replace





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE I.2: 	Scatter plot of binned drive time
*
*			Description:
*-------------------------------------------------------------------------------


* preserve and keep
*------------------

preserve
keep if pp_has_changed == 1



* bins
*-----

capture drop drive_time_bin
gen drive_time_bin = .
label var drive_time_bin "bins for pp_minutes_driving_change"


gen abs_change = abs(pp_minutes_driving_change)
sum abs_change, d

local upper	 		= -int(r(p99))
local end_value 	= int(r(p99))
local increment		= 2
local range 		= "(pp_minutes_driving_change > `upper' & pp_minutes_driving_change < `end_value')"


while `upper' <= `end_value'  {

	local lower = `upper' - `increment'
	local midvalue = `upper' - (`increment' / 2)

	display "Upper: `upper'"
	display "Lower: `lower'"
	display "MidValue: `midvalue'"

	replace drive_time_bin = `midvalue'  		if pp_minutes_driving_change >= `lower' 	& pp_minutes_driving_change < `upper'
	local upper = `upper' + `increment'


}




* tag bin
*--------

capture drop tag_bin
egen tag_bin = tag(drive_time_bin)
label var tag_bin "tag for 1 observation in each drive time bin"



* loop to plot
*-------------

local outcomes = "voted_ANY"


foreach x of local outcomes {

	* labels
	*-------

		if "`x'" == "voted_ANY"{
			local out = "% Turnout"
			local out2 = "ANY"
			local scale = ".7(.1).9"
		}


	* averages within bins
	*---------------------

	capture drop `x'_b
	bysort drive_time_bin: egen `x'_b = mean(`x')


	* count observations within bins
	*-------------------------------

	capture drop count_bin
	bysort drive_time_bin: egen count_bin = count(`x')



	* plot
	*-----

	#delimit ;

		twoway

			( scatter `x'_b 	drive_time_bin   	[aweight=count_bin]
						if tag_bin == 1 & `range'
				, msize(large) mcolor(gs4) msymbol(circle_hollow) )

			//( lfitci `x' 		pp_minutes_driving_change					if (tag_bin == 1 | tag_bin != 1) & `range'
			  //,  clwidth(medium) clcolor(black) alcolor(gs8) alwidth(medthick)
				//alpattern(line) fcolor(none) xline(0, lcolor(gs8)) )

			( lpolyci `x' 		pp_minutes_driving_change
						if (tag_bin == 1 | tag_bin != 1) & (pp_minutes_driving_change >= -10 & pp_minutes_driving_change <= 10)
			  ,  clwidth(medium) clpattern(dash) clcolor(black) alcolor(black) alwidth(medthick)
			     alpattern(dot) fcolor(none) deg(1) bwidth(3)  xline(0, lcolor(gs8)) )

			,

			ylabel( `scale',
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("`out'",
				angle(hori)	color(black) size(medium) )

			xlabel(  -10(5)10,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Drive Time to Polling Place, Minutes",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_DriveTime_`out2'.pdf, replace


	* drop
	*-----

	drop `x'_b
	drop count_bin


}



* restore
*--------

restore


			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE ?: 	Distribution of drive time changes
*
*		Description: By year
*-------------------------------------------------------------------------------



* plot
*-----

	#delimit ;

		twoway

			( kdensity pp_minutes_driving_change   	if  pp_has_changed == 1 & year == 2012
				, xline(0, lcolor(gs10)) lcolor(black) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Drive Time to Polling Place, Minutes",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_DriveTime_2012.pdf, replace






* plot
*-----

	#delimit ;

		twoway

			( kdensity pp_minutes_driving_change   	if  pp_has_changed == 1 & year == 2016
				, xline(0, lcolor(gs10)) lcolor(gs4) lpattern(dash) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Change in Drive Time to Polling Place, Minutes",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_DriveTime_2016.pdf, replace





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE J.1:	 Distribution of early voting availability
*
*			Description:	Distribution by total, evening, weekend & locations
*-------------------------------------------------------------------------------

* tag county and county_by_year
*------------------------------

capture drop tag_ct
capture drop tag_ct_year

egen tag_ct = tag(county_fips)
egen tag_ct_year = tag(county_fips year)



* plot: number of hours
*----------------------

	#delimit ;

		twoway

			( kdensity early_vote_total_hours   	if tag_ct_year == 1 & year == 2012
				,  lcolor(black) )

			( kdensity early_vote_total_hours   	if tag_ct_year == 1 & year == 2016
				,  lcolor(gs7) lpattern(longdash) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Hours per County",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( order(
				1 "2012"
				2 "2016"
				)
				cols(1)
				region( color(none) )
				size(medium)
				pos(2)	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_Early_Hours.pdf, replace




* plot: number of sites
*----------------------

	#delimit ;

		twoway

			( kdensity early_vote_number_of_sites   	if tag_ct_year == 1 & year == 2012
				,  lcolor(black) )

			( kdensity early_vote_number_of_sites   	if tag_ct_year == 1 & year == 2016
				,  lcolor(gs7) lpattern(longdash) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Locations per County",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( order(
				1 "2012"
				2 "2016"
				)
			cols(1)
			region( color(none) )
			size(medium)
			pos(2)
				)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_Early_Locations.pdf, replace




* early voting weekend hours
*---------------------------

capture drop early_vote_weekend
gen early_vote_weekend = early_vote_saturday_hours + early_vote_sunday_hours



* plot: weekend hours
*--------------------

	#delimit ;

		twoway

			( kdensity early_vote_weekend   	if tag_ct_year == 1 & year == 2012
				,  lcolor(black) )

			( kdensity early_vote_weekend   	if tag_ct_year == 1 & year == 2016
				,  lcolor(gs7) lpattern(longdash) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Weekend Hours per County",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( order(
				1 "2012"
				2 "2016"
				)
			cols(1)
			region( color(none) )
			size(medium)
			pos(2)	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_EarlyWeekend.pdf, replace



* plot: weekend hours
*--------------------

	#delimit ;

		twoway

			( kdensity early_vote_evening_hours   	if tag_ct_year == 1 & year == 2012
				,  lcolor(black) )

			( kdensity early_vote_evening_hours   	if tag_ct_year == 1 & year == 2016
				,  lcolor(gs7) lpattern(longdash) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Evening Hours per County",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( order(
				1 "2012"
				2 "2016"
				)
			cols(1)
			region( color(none) )
			size(medium)
			pos(2)	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_EarlyEvening.pdf, replace




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE J.2:	 Scatterplot of 2012/2016 hours and locations (Appendix)
*
*		Description: Which counties are having their early voting hours changed
*-------------------------------------------------------------------------------


* county group
*-------------

capture drop county_group
egen county_group = group(county_fips)
label var county_group "sequential county numeric"


* early voting weekend hours
*---------------------------

capture drop early_vote_weekend
gen early_vote_weekend = early_vote_saturday_hours + early_vote_sunday_hours



* tag county year
*----------------

capture drop tag_ct
egen tag_ct = tag(county )
label var tag_ct "tag =1 for each unique county"



* loop
*-----

local outcomes = "number_of_sites evening_hours total_hours weekend"


foreach x of local outcomes {

	capture drop test
	capture drop early_vote_`x'_2016
	capture drop early_vote_`x'_2012

	bysort county_group: gen test = early_vote_`x' if year == 2012
	bysort county_group: egen early_vote_`x'_2012 = max(test)
	drop test

	bysort county_group: gen test = early_vote_`x' if year == 2016
	bysort county_group: egen early_vote_`x'_2016 = max(test)
	drop test



	* plot: 2012/2016 scatterplot
	*----------------------------

	#delimit ;

		twoway

			( scatter early_vote_`x'_2016  early_vote_`x'_2012
				if tag_ct == 1
				,  mcolor(black)  msize(medsmall)  msymbol(Oh) jitter(3) )
			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("2016",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("2012",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_`x'_2012_vs_2016.pdf, replace

}




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE J.3:	 Early Hours: Weekend, Evening (Appendix)
*
*		Description: Early hours by type
*-------------------------------------------------------------------------------



* county group
*-------------

capture drop county_group
egen county_group = group(county_fips)
label var county_group "sequential county numeric"


* early voting weekend hours
*---------------------------

capture drop early_vote_weekend
gen early_vote_weekend = early_vote_saturday_hours + early_vote_sunday_hours



* county mean early voting
*-------------------------

capture drop vote_early_ct_mean
bysort county_group year: egen vote_early_ct_mean = mean(voted_early)
label var vote_early_ct_mean "proportion of the county voters voting early, by year"

capture drop tag_ct_year
egen tag_ct_year = tag(county year)
label var tag_ct_year "tag =1 for each unique county year pair"



* registered voters by county
*----------------------------

capture drop total_reg_voters_ct
bysort county_group year: egen total_reg_voters_ct = count(ncid)
label var total_reg_voters_ct "total registered voters by county by year"



* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_early"
global dv2					= "voted_elecday"
global dv3					= "voted_ANY"
global number_of_outcomes	= 3

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed"

global controlsfull			= "voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag age age2 female black hispanic unknown other native_am asian multi_race census_hh_med_income party_rep party_una party_lib"
global controls				= "voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag black_x_year hispanic_x_year unknown_x_year other_x_year native_am_x_year asian_x_year multi_race_x_year"

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster1				= "ncid"
global cluster2				= "county_fips"



* new variables to store the regression output
*---------------------------------------------

capture drop beta1
capture drop beta2
capture drop beta3
capture drop se1
capture drop se2
capture drop se3

gen beta1 = .
gen se1 = .

gen beta2 = .
gen se2 = .

gen beta3 = .
gen se3 = .



* estimate each beta
*-------------------

local years = "2012 2016"

foreach y of local years {

	forvalues x = 1/100 {

		reg ${dv1} ${iv1}  ${controlsfull} 	if county_group == `x' & year == `y' ///
					, vce(robust)

		display "YEAR: `y'"
		display "County: `x'"
		replace beta1 	= _b[pp_has_changed]  	if county_group == `x' & year == `y'
		replace se1 		= _se[pp_has_changed]	if county_group == `x' & year == `y'


		reg ${dv2} ${iv1}  ${controlsfull} 	if county_group == `x' & year == `y' ///
					, vce(robust)

		replace beta2 	= _b[pp_has_changed]  	if county_group == `x' & year == `y'
		replace se2 	= _se[pp_has_changed]	if county_group == `x' & year == `y'


		reg ${dv3} ${iv1}  ${controlsfull} 	if county_group == `x' & year == `y' ///
					, vce(robust)

		replace beta3 	= _b[pp_has_changed]  	if county_group == `x' & year == `y'
		replace se3 	= _se[pp_has_changed]	if county_group == `x' & year == `y'

	}
}






* plot: evening & early vote
*----------------------------

	#delimit ;

		twoway

			( scatter beta1 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Evening Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyEvening_EarlyVote.pdf, replace




* plot: weekend & early vote
*----------------------------

	#delimit ;

		twoway

			( scatter beta1 early_vote_weekend
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_weekend
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_weekend
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_weekend
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Total Early Voting Weekend Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyWeekend_EarlyVote.pdf, replace



* plot: evening & elecday vote
*----------------------------

	#delimit ;

		twoway

			( scatter beta2 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta2 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta2 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta2 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Elec Day Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Weekend Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyEvening_ElecVote.pdf, replace




* plot: weekend & elecday vote
*----------------------------

	#delimit ;

		twoway

			( scatter beta2 early_vote_weekend
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta2 early_vote_weekend
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta2 early_vote_weekend
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta2 early_vote_weekend
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Elec Day Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Total Early Voting Weekend Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyWeekend_ElecVote.pdf, replace




* plot: evening & ANY vote
*----------------------------

	#delimit ;

		twoway

			( scatter beta3 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta3 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta3 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta3 early_vote_evening_hours
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Total Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Number of Early Voting Evening Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyEvening_TotalVote.pdf, replace




* plot: weekend & ANY vote
*-------------------------

	#delimit ;

		twoway

			( scatter beta3 early_vote_weekend
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta3 early_vote_weekend
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta3 early_vote_weekend
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta3 early_vote_weekend
				if tag_ct_year == 1 & year == 2016
				,  lcolor(gs8)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Total Early Voting Weekend Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyWeekend_TotalVote.pdf, replace





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE I.2:	 Distribution of voter age
*
*		Description: Density
*-------------------------------------------------------------------------------


* plot
*-----

	#delimit ;

		twoway

			( kdensity age
				,  bwidth(4) lcolor(black) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Density",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Age",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Distribution_Age.pdf, replace



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* 	APPENDIX FIGURE J.3:	 Normalized early voting availability
*
*		Description: Hours, Locations, Weekend Hours, Evening Hours
*-------------------------------------------------------------------------------


* county group
*-------------
set more off
capture drop county_group
egen county_group = group(county_fips)
label var county_group "sequential county numeric"


* tag county
*-----------

capture drop tag_ct_year
egen tag_ct_year = tag(county year)
label var tag_ct_year "tag =1 for each unique county year pair"



* registered voters by county
*----------------------------

capture drop total_reg_voters_ct
bysort county_group year: egen total_reg_voters_ct = count(ncid)
label var total_reg_voters_ct "total registered voters by county by year"




* normalize
*----------

capture drop early_vote_weekend_norm
gen early_vote_weekend_norm 			= (early_vote_saturday_hours + early_vote_sunday_hours) / total_reg_voters_ct

capture drop early_vote_evening_hours_norm
gen early_vote_evening_hours_norm 		= early_vote_evening_hours / total_reg_voters_ct

capture drop early_vote_number_of_sites_norm
gen early_vote_number_of_sites_norm 	= early_vote_number_of_sites / total_reg_voters_ct if county_name != "Tyrrell"

capture drop early_vote_total_hours_norm
gen early_vote_total_hours_norm 		= early_vote_total_hours / total_reg_voters_ct if county_name != "Tyrrell"



* globals for specifications
*---------------------------
clean_globals

global dv1					= "voted_early"

global iv1					= "pp_has_changed"

global controlsfull			= "voted_elecday_lag voted_early_lag voted_mailin_lag voted_weird_lag age age2 female black hispanic unknown other native_am asian multi_race census_hh_med_income party_rep party_una party_lib"

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster1				= "ncid"
global cluster2				= "county_fips"



* new variables to store the regression output
*---------------------------------------------

capture drop beta1
capture drop se1


gen beta1 = .
gen se1 = .




* estimate each beta
*-------------------

local years = "2012 2016"

foreach y of local years {

	forvalues x = 1/100 {

		reg ${dv1} ${iv1}  ${controlsfull} 	if county_group == `x' & year == `y' ///
					, vce(robust)


		display "YEAR: `y'"
		display "County: `x'"
		replace beta1 	= _b[pp_has_changed]  	if county_group == `x' & year == `y'
		replace se1 	= _se[pp_has_changed]	if county_group == `x' & year == `y'

	}
}






* plot: weekend & early
*----------------------

	#delimit ;

		twoway

			( scatter beta1 early_vote_weekend_norm
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_weekend_norm
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_weekend_norm
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_weekend_norm
				if tag_ct_year == 1 & year == 2016
				,  lcolor(black)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Normalized Early Voting Weekend Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyWeekend_EarlyVote_Norm.pdf, replace




* plot: evening & early
*----------------------

	#delimit ;

		twoway

			( scatter beta1 early_vote_evening_hours_norm
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_evening_hours_norm
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_evening_hours_norm
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_evening_hours_norm
				if tag_ct_year == 1 & year == 2016
				,  lcolor(black)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Normalized Early Voting Evening Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyEvening_EarlyVote_Norm.pdf, replace



* plot: hours total & early
*--------------------------

	#delimit ;

		twoway

			( scatter beta1 early_vote_total_hours_norm
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_total_hours_norm
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_total_hours_norm
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_total_hours_norm
				if tag_ct_year == 1 & year == 2016
				,  lcolor(black)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Normalized Early Voting Total Hours",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyHours_EarlyVote_Norm.pdf, replace




* plot: locations total & early
*------------------------------

	#delimit ;

		twoway

			( scatter beta1 early_vote_number_of_sites_norm
				if tag_ct_year == 1 & year == 2012
				,  mcolor(black)  msize(medsmall) jitter(3) )

			( lfitci beta1 early_vote_number_of_sites_norm
				if tag_ct_year == 1 & year == 2012
				,  lcolor(black) fcolor(none) alcolor(black) alpattern(dot) )

			( scatter beta1 early_vote_number_of_sites_norm
				if tag_ct_year == 1 & year == 2016
				,  mcolor(gs8)  msize(medium) msymbol(Oh) jitter(3) )

			( lfitci beta1 early_vote_number_of_sites_norm
				if tag_ct_year == 1 & year == 2016
				,  lcolor(black)  lpattern(longdash) fcolor(none) alcolor(black) alpattern(dot) )

			,

			ylabel( ,
				tlength(0) angle(hori) nogrid labsize(medsmall) )
			ytitle("Partial Corr. of PP Change and Early Voting",
				angle(hori)	color(black) size(medium) )

			xlabel(  ,
				labsize(medsmall) tlcolor(black) labcolor(black) )
			xtitle("Normalized Total Early Voting Locations",
				color(black) size(medium) )

			xscale(noline)
			yscale(noline)
			graphregion(fcolor(white) lcolor(white) )
			plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
			title("  ",
				color(black) size(medsmall) pos(5) )
			subtitle("",
				color(black) justification(center))
			legend( off	)

			;

	#delimit cr


	* output
	*-------

		capture cd "${output}"
		capture graph export Plot_Scatter_EarlyLocations_EarlyVote_Norm.pdf, replace








			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**

					** end of do file **
