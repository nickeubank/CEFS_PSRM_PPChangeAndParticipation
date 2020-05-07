
    ************************************************************************
    **
    **
    **        PROJECT AUTHORS:    CLINTON, EUBANK, FRESH & SHEPHERD
    **        DO FILE AUTHOR:        EUBANK
    **        DATE BEGUN:         March 17, 2018
    **
    **        PROJECT:             NC Electioneering
    **        DETAILS:
    **
    **        UPDATES: Add data from NHGIS for voters' census blocks
    **
    **
    **        VERSION:             Stata 14
    **
    **
    *************************************************************************



                **    **    **    **    **    **    **    **    **    **    **    **    **
                **    **    **    **    **    **    **    **    **    **    **    **    **
                **    **    **    **    **    **    **    **    **    **    **    **    **



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
* Get census vars
*-------------------------------------------------------------------------------

insheet using 00_source_data/census_data/nhgis_incomedata/nhgis0008_ds176_20105_2010_blck_grp.csv, clear

keep gisjoin joie001 joke001 joqe001 jore001
* Others might want some day: year regiona divisiona state statea county countya cousuba placea tracta blkgrpa

rename joie001 census_hh_med_income
label var census_hh_med_income "median household income in block group"

rename joke001 census_hh_med_income_black
label var census_hh_med_income_black "median household income in block group for black only households"
rename joqe001 census_hh_med_income_white
label var census_hh_med_income_white "median household income in block group for white only households"
rename jore001 census_hh_med_income_hispanic
label var census_hh_med_income_hispanic "median household income in block group for hispanic only households"


* Destring and deal with two pads that are in NHGIS we don't have
* in our block groups
replace gisjoin = subinstr(gisjoin, "G370", "37", .)
destring gisjoin, replace
recast double gisjoin
format gisjoin %14.0f

* Pull out extra pad. Note need to go through string format
* to deal with leading zeros and, more importantly,
* then tendency of stata to convert to floats.
* Can't multiply front by cut and add to back --
* imprecisions ruin front.

local cut = 100000000
gen front = int(gisjoin / `cut')
gen middle = int(mod(gisjoin, `cut') / (`cut' / 10))
gen back = mod(gisjoin, `cut'/10)
assert middle == 0
drop middle
tostring front, replace
tostring back, replace  format(%07.0f)

egen voter_census_blockgroup = concat(front back)
destring voter_census_blockgroup, replace
format voter_census_blockgroup %14.0f
assert voter_census_blockgroup  < 10^12
assert voter_census_blockgroup  > 10^11
duplicates report voter_census_blockgroup
assert r(N) == r(unique_value)
drop front back

drop gisjoin
tempfile census_vars
save `census_vars', replace



        **    **    **    **    **    **    **    **    **    **    **    **    **
        **    **    **    **    **    **    **    **    **    **    **    **    **
        **    **    **    **    **    **    **    **    **    **    **    **    **

*-------------------------------------------------------------------------------
* Merge with panel
*-------------------------------------------------------------------------------

if "$sample_size" == "full" {
    zipuse 20_intermediate_files/50_voter_panel_long_subsampled_dta.zip, clear
}
else {
    use 20_intermediate_files/50_voter_panel_10pctsample_long_subsampled.dta, clear
}



* Make census block group vars
*--------------

rename census_block voter_census_block
label var  voter_census_block "voter's census block"
format voter_census_block  %16.0f
recast double voter_census_block

* Drop last 4 digits. Can't do with math because
* stupid stata converts everything to floats and loses
* precision.
tostring voter_census_block, gen(temp) format(%16.0f)
gen voter_census_blockgroup = regexr(temp, "[0-9][0-9][0-9]$", "")
destring  voter_census_blockgroup, replace
label var voter_census_blockgroup "voter's census block group (above block, under tract)"
format voter_census_blockgroup  %16.0f
drop temp

sort voter_census_blockgroup
merge m:1 voter_census_blockgroup using `census_vars'
assert _m != 1
drop if _m == 2
drop _m

* Check using poor ==> black.
gen temp_black = race != 0
corr census_hh_med_income temp_black
assert r(rho) < - 0.15
drop temp_black

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
    zipsave 20_intermediate_files/50_voter_panel_long_subsampled_wcensus_dta.zip, replace
}
else {
    save 20_intermediate_files/50_voter_panel_10pctsample_long_subsampled_wcensus.dta, replace
}







            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **
            **    **    **    **    **    **    **    **    **    **    **    **    **

             ** end of 10_reshape_long_add_analysis_vars.do **
