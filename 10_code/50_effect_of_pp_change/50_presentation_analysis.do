
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



* use the data
*-------------

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/60_voter_panel_long_w_analysisvars_no_movers_dta.zip, clear
}
else {
    use 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_no_movers.dta, clear
}






* define output directory
*------------------------

global output "${nc_electioneering}50_results_$sample_size"






			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* define globals for outputting individual values
*-------------------------------------------------------------------------------


global closef = "capture file close myfile"
global openf = "file open myfile using"
global writef = "file write myfile"





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




* pull out i.race
*----------------

gen white		= 1  if race == 0
//gen black		= 1  if race == 1
gen unknown		= 1  if race == 2
gen other		= 1  if race == 3
gen native_am	= 1  if race == 4
gen asian		= 1  if race == 5
gen multi_race	= 1  if race == 6

local races = "white unknown other native_am asian multi_race"

foreach race of local races {

		replace `race' = 0 	if `race' == .

}



* non-white and interaction
*--------------------------

gen nwhite = 1 if white == 0
replace nwhite = 0 if nwhite == .

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
gen party_ind = 1 if party == 2
gen party_lib = 1 if party == 3

local parties = "dem rep ind lib"

foreach party of local parties {

		replace party_`party' = 0 	if party_`party' == .

}



* race by year
*-------------

local races = "white black unknown other native_am asian multi_race"

foreach race of local races {

	gen `race'_x_year 			= `race' * year
	gen `race'_x_pp_has_changed = `race' * pp_has_changed

}




			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**

							** PLOTS **

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* aggregate turnout plot
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

global dv1					= "voted_ANY"
global number_of_outcomes	= 1

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed"

global controls				= "black_x_year unknown_x_year other_x_year native_am_x_year asian_x_year multi_race_x_year"
global controlsfull			= "age age2 female black unknown other native_am asian multi_race census_hh_med_income voted_last party_rep party_ind party_lib"

global year1				= "year == 2012"
global year2				= "year == 2016"


global cluster1				= "ncid"
global cluster2				= "county_fips"




* temp file
*----------

tempname memhold
tempfile results
postfile `memhold' beta se spec   using `results'




* regressions
*------------

// panel
xi:	areg ${dv1} ${iv1}  ${controls} , vce(cl ${cluster1})  absorb(ncid)

	post `memhold' (_b[${iv1}]) (_se[${iv1}]) (1)


// 2012 only
xi:		areg ${dv1} ${iv2} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)

	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (2)


// 2016 only
xi:		areg ${dv1} ${iv2} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)

	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (3)





* post close
*-----------

preserve
postclose `memhold'
use `results', clear



* generate ci
*------------

gen sortid = _n
gen cihi = beta + 1.96*se
gen cilo = beta - 1.96*se



* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec
			, lwidth(medthick) color(none) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec
			, color(none)  msize(medium)
			)

			,

		ylabel( -.02(.01).02,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " "  ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
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
	capture graph export Plot_Aggregate_0.pdf, replace



* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec
			, lwidth(medthick) color(black) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec
			, color(black)  msize(medium)
			)

			,

		ylabel( -.02(.01).02,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " "  ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
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
	capture graph export Plot_Aggregate_1.pdf, replace




* restore
*--------

restore



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**


*-------------------------------------------------------------------------------
* aggregate turnout plot with heterogenous race effects
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

global dv1					= "voted_ANY"
global number_of_outcomes	= 1

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed_x_nwhite"
global iv3					= "nwhite_x_year"

global iv4					= "pp_has_changed_x_nwhite"
global iv5					= "nwhite"

global controls				= ""
global controlsfull			= "age age2 female census_hh_med_income voted_last party_rep party_ind party_lib"

global year1				= "year == 2012"
global year2				= "year == 2016"

global cluster1				= "ncid"
global cluster2				= "county_fips"




* temp file
*----------

tempname memhold
tempfile results
postfile `memhold' beta se spec  tag  using `results'




* regressions
*------------

// panel
xi:	areg ${dv1} ${iv1} ${iv2} ${iv3} ${controls} , vce(cl ${cluster1})  absorb(ncid)
	post `memhold' (_b[${iv1}]) (_se[${iv1}])  (1)  (1)

xi:	areg ${dv1} ${iv1} ${iv2} ${iv3} ${controls} , vce(cl ${cluster1})  absorb(ncid)
	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (1.2) (2)


// 2012 only
xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv1}]) (_se[${iv1}])  (2) (1)

xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv4}]) (_se[${iv4}]) (2.2) (2)


// 2016 only
xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv1}]) (_se[${iv1}]) (3) (1)

xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv4}]) (_se[${iv4}]) (3.2)  (2)



* post close
*-----------

preserve
postclose `memhold'
use `results', clear



* generate ci
*------------

gen sortid = _n
gen cihi = beta + 1.96*se
gen cilo = beta - 1.96*se



* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec
			, lwidth(medthick) color(none) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec
			, color(none)  msize(medium)
			)

			,

		ylabel( ,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " "  ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
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
	capture graph export Plot_Aggregate_Hetero_0.pdf, replace



* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec  if tag == 1
			, lwidth(medthick) color(black) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec		if tag == 1
			, color(black)  msize(medium)
			)


		( rcap cihi cilo spec  if tag == 2
			, lwidth(medthick) color(gs9) msize(vtiny)
			)
		( scatter beta spec		if tag == 2
			, color(gs9)  msize(medium)  msymbol(D)
			)

			,

		ylabel( ,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " "  ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
		yscale(noline)
		graphregion(fcolor(white) lcolor(white) )
		plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
		title("  ",
			color(black) size(medsmall) pos(5) )
		subtitle("",
			color(black) justification(center))
		legend(order(
			2 ""
			4 "")
			symx(8)
			cols(1)
			ring(0)
			pos(11)
			region( color(none) )
			size(vsmall)   )
		;

		#delimit cr




* output
*-------

	capture cd "${output}"
	capture graph export Plot_Aggregate_Hetero_1.pdf, replace




* restore
*--------

restore





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* substitution plot
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

global dv2					= "voted_early"
global dv1					= "voted_elecday"
global number_of_outcomes	= 2

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed"

global controls				= "black_x_year unknown_x_year other_x_year native_am_x_year asian_x_year multi_race_x_year"
global controlsfull			= "age age2 female black unknown other native_am asian multi_race census_hh_med_income voted_last party_rep party_ind party_lib"

global year1				= "year == 2012"
global year2				= "year == 2016"


global cluster1				= "ncid"
global cluster2				= "county_fips"




* temp file
*----------

tempname memhold
tempfile results
postfile `memhold' beta se spec   using `results'




* regressions
*------------

// panel
xi:	areg ${dv1} ${iv1}  ${controls} , vce(cl ${cluster1})  absorb(ncid)

	post `memhold' (_b[${iv1}]) (_se[${iv1}]) (1)


// 2012 only
xi:		areg ${dv1} ${iv2} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)

	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (2)


// 2016 only
xi:		areg ${dv1} ${iv2} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)

	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (3)


// panel
xi:	areg ${dv2} ${iv1}  ${controls} , vce(cl ${cluster1})  absorb(ncid)

	post `memhold' (_b[${iv1}]) (_se[${iv1}]) (4)


// 2012 only
xi:		areg ${dv2} ${iv2} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)

	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (5)


// 2016 only
xi:		areg ${dv2} ${iv2} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)

	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (6)




* post close
*-----------

preserve
postclose `memhold'
use `results', clear



* generate ci
*------------

gen sortid = _n
gen cihi = beta + 1.96*se
gen cilo = beta - 1.96*se



* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec
			, lwidth(medthick) color(none) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec
			, color(none)  msize(medium)
			)

			,

		ylabel(-0.05(.025).05 ,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " " 4 " " 5 " " 6 " " ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
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
	capture graph export Plot_Substitution_0.pdf, replace




* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec	if spec <= 3
			, lwidth(medthick) color(black) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec		if spec <= 3
			, color(black)  msize(medium)
			)


		( rcap cihi cilo spec	if spec > 3
			, lwidth(medthick) color(none) msize(vtiny)
			 )
		( scatter beta spec		if spec > 3
			, color(none)  msize(medium)  msymbol(Oh)
			)

			,

		ylabel( -0.05(.025).05,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " " 4 " " 5 " " 6 " " ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
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
	capture graph export Plot_Substitution_1.pdf, replace




* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec	if spec <= 3
			, lwidth(medthick) color(black) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec		if spec <= 3
			, color(black)  msize(medium)
			)


		( rcap cihi cilo spec	if spec > 3
			, lwidth(medthick) color(black) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec		if spec > 3
			, color(black)  msize(medium)  msymbol(Oh)
			)

			,

		ylabel( -0.05(.025).05,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " " 4 " " 5 " " 6 " " ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
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
	capture graph export Plot_Substitution_2.pdf, replace




* restore
*--------

restore



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**



*-------------------------------------------------------------------------------
* aggregate turnout plot with heterogenous race effects
*-------------------------------------------------------------------------------


* globals for specifications
*---------------------------

global dv2					= "voted_early"
global dv1					= "voted_elecday"
global number_of_outcomes	= 1

global iv1					= "pp_has_changed"
global iv2					= "pp_has_changed_x_nwhite"
global iv3					= "nwhite_x_year"

global iv4					= "pp_has_changed_x_nwhite"
global iv5					= "nwhite"

global controls				= ""
global controlsfull			= "age age2 female census_hh_med_income voted_last party_rep party_ind party_lib"

global year1				= "year == 2012"
global year2				= "year == 2016"


global cluster1				= "ncid"
global cluster2				= "county_fips"




* temp file
*----------

tempname memhold
tempfile results
postfile `memhold' beta se spec  tag  using `results'




* regressions
*------------

// panel
xi:	areg ${dv1} ${iv1} ${iv2} ${iv3} ${controls} , vce(cl ${cluster1})  absorb(ncid)
	post `memhold' (_b[${iv1}]) (_se[${iv1}])  (1)  (1)

xi:	areg ${dv1} ${iv1} ${iv2} ${iv3} ${controls} , vce(cl ${cluster1})  absorb(ncid)
	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (1.1) (2)


// 2012 only
xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv1}]) (_se[${iv1}])  (2) (1)

xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv4}]) (_se[${iv4}]) (2.1) (2)


// 2016 only
xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv1}]) (_se[${iv1}]) (3) (1)

xi:		areg ${dv1} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv4}]) (_se[${iv4}]) (3.1)  (2)


	** ** **


// panel
xi:	areg ${dv2} ${iv1} ${iv2} ${iv3} ${controls} , vce(cl ${cluster1})  absorb(ncid)
	post `memhold' (_b[${iv1}]) (_se[${iv1}])  (4)  (1)

xi:	areg ${dv2} ${iv1} ${iv2} ${iv3} ${controls} , vce(cl ${cluster1})  absorb(ncid)
	post `memhold' (_b[${iv2}]) (_se[${iv2}]) (4.1) (2)


// 2012 only
xi:		areg ${dv2} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv1}]) (_se[${iv1}])  (5) (1)

xi:		areg ${dv2} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year1}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv4}]) (_se[${iv4}]) (5.1) (2)


// 2016 only
xi:		areg ${dv2} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv1}]) (_se[${iv1}]) (6) (1)

xi:		areg ${dv2} ${iv1} ${iv4} ${iv5} ${controlsfull} if  ${year2}, vce(cl ${cluster2}) a(county_fips)
	post `memhold' (_b[${iv4}]) (_se[${iv4}]) (6.1)  (2)



* post close
*-----------

preserve
postclose `memhold'
use `results', clear



* generate ci
*------------

gen sortid = _n
gen cihi = beta + 1.96*se
gen cilo = beta - 1.96*se



* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec
			, lwidth(medthick) color(none) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec
			, color(none)  msize(medium)
			)

			,

		ylabel(  -0.05(.025).05,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " " 4 " " 5 " " 6 " "  ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
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
	capture graph export Plot_Substitution_Hetero_0.pdf, replace



* plot
*-----

#delimit;

	twoway

		( rcap cihi cilo spec  if tag == 1 & spec < 4
			, lwidth(medthick) color(black) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec		if tag == 1 & spec < 4
			, color(black)  msize(medium)
			)


		( rcap cihi cilo spec  if tag == 2  & spec < 4
			, lwidth(medthick) color(gs9) msize(vtiny)
			)
		( scatter beta spec		if tag == 2  & spec < 4
			, color(gs9)  msize(medium)  msymbol(D)
			)


		( rcap cihi cilo spec  if tag == 1 & spec >= 4
			, lwidth(medthick) color(black) msize(vtiny)
			  yline(0, lwidth(medthick) lcolor(gs9) lpattern(dash) )
			)
		( scatter beta spec		if tag == 1 & spec >= 4
			, color(black)  msize(medium) msymbol(Oh)
			)


		( rcap cihi cilo spec  if tag == 2  & spec >= 4
			, lwidth(medthick) color(gs9) msize(vtiny)
			)
		( scatter beta spec		if tag == 2  & spec >= 4
			, color(gs9)  msize(medium)  msymbol(Dh)
			)
			,

		ylabel(  -0.05(.025).05,
			tlength(0) angle(hori) nogrid labsize(small) )
		ytitle("Estimated Effect of Polling Place Change",
			angle(hori)	color(black) size(medsmall) )

		xlabel(1 " " 2 " " 3 " " 4 " " 5 " " 6 " "  ,
			tlength(0) labsize(small) tlcolor(none) labcolor(none) )
		xtitle(" ",
			color(none) size(vsmall) )

		xscale(noline)
		yscale(noline)
		graphregion(fcolor(white) lcolor(white) )
		plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))
		title("  ",
			color(black) size(medsmall) pos(5) )
		subtitle("",
			color(black) justification(center))
		legend(order(
			2 ""
			6 ""
			4 ""
			8 "")
			symx(8)
			cols(1)
			ring(0)
			pos(11)
			region( color(none) )
			size(vsmall)   )
		;

		#delimit cr




* output
*-------

	capture cd "${output}"
	capture graph export Plot_Substitution_Hetero_1.pdf, replace




* restore
*--------

restore
