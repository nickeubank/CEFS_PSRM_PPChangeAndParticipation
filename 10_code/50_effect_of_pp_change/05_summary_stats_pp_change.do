  ************************************************************************
    **
    **
    **        PROJECT AUTHORS:    CLINTON, EUBANK, FRESH & SHEPHERD
    **        DO FILE AUTHOR:     CLINTON
    **        DATE BEGUN:         February 27, 2018
    **
    **        PROJECT:             NC Electioneering
    **        DETAILS:
    **
    **        UPDATES:  Reads in full panel, creates descriptives of pp change
    **                        impacts.
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
    zipuse 20_intermediate_files/60_voter_panel_long_w_analysisvars_no_movers_dta.zip, clear
}
else {
    use 20_intermediate_files/60_voter_panel_10pctsample_long_w_analysisvars_no_movers.dta, clear

}




*-------------------------------------------------------------------------------
* PP Change impact summary stats
*-------------------------------------------------------------------------------

* Impacted 2008-2012


foreach year in 2012 2016 {
    sum pp_has_changed if year == `year'

    local cleaned_statistic: display %12.0fc `r(mean)' * 100
    display "`cleaned_statistic'"

    * Write to disk.
    * This syntax looks odd, but what it's doing is creating
    * a "handle" to a file, writing to that handle,
    * then closing the file when done.

    file open myfile using $nc_electioneering/50_results_$sample_size/ppchange_impacted_`year'.tex, write text replace
    file write myfile "`cleaned_statistic'"
    file close myfile
}
