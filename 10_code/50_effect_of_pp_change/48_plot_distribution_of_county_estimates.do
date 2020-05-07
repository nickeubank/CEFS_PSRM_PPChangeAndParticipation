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
