

* PAPER SPECIFICATIONS
*---------------------


cd "${output}"




* clear eststo
*-------------

_eststo clear





* specification 1
*----------------

local estimate = "est_1"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv1} ${iv1}  ${controls_crosssection_income} ///
									if  ${year1}, vce(cl ${cluster2}) a(${cluster2})

				summary_stats "`estimate'" ${dv1} ${cluster2}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2012": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'







* specification 2
*----------------

local estimate = "est_2"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv1} ${iv1}  ${controls_crosssection_income} ///
									if  ${year2}, vce(cl ${cluster2}) a(${cluster2})

			    summary_stats "`estimate'" ${dv1} ${cluster2}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2016": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'




* specification 3
*----------------

local estimate = "est_3"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv2} ${iv1}  ${controls_crosssection_income} ///
									if  ${year1}, vce(cl ${cluster2}) a(${cluster2})

				summary_stats "`estimate'" ${dv2} ${cluster2}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2012": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'



* specification 4
*----------------

local estimate = "est_4"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv2} ${iv1}  ${controls_crosssection_income} ///
									if  ${year2}, vce(cl ${cluster2}) a(${cluster2})

				summary_stats "`estimate'" ${dv2} ${cluster2}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2016": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'






* specification 5
*----------------

local estimate = "est_5"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv3} ${iv1}  ${controls_crosssection_income} ///
									if  ${year1}, vce(cl ${cluster2}) a(${cluster2})

				summary_stats "`estimate'" ${dv3} ${cluster2}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2012": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'


* specification 6
*----------------

local estimate = "est_6"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv3} ${iv1}  ${controls_crosssection_income} ///
									if  ${year2}, vce(cl ${cluster2}) a(${cluster2})

				summary_stats "`estimate'" ${dv3} ${cluster2}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2016": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'



* output the regressions
*-----------------------


	cd "${output}"

	#delimit;

	esttab

		est_1
		est_2
		est_3
		est_4
		est_5
		est_6



		using "${filename}.tex",
			b(a2) label replace nogaps compress se(a2) bookt
			noconstant nodepvars star(* 0.1 ** 0.05 *** 0.01)
			fragment keep(${iv1} )


			stats(countyfe controls sample N meandv stddv ,
				labels(	"County FE"
						"Individual Controls"
						"Year Sample"
						"Observations"
						"Mean of DV"
						"SD of DV"

						) )
			title("")
			nomtitles


		;

	#delimit cr

	cd "${output}"

	#delimit;

	esttab

		est_1
		est_2
		est_3
		est_4
		est_5
		est_6



		using "${filename}_wcontrols.tex",
			b(a2) label replace nogaps compress se(a2) bookt
			noconstant nodepvars star(* 0.1 ** 0.05 *** 0.01)
			fragment keep(${iv1}  ${controls_crosssection_income})


			stats(countyfe sample N meandv stddv ,
				labels(	"County FE"
						"Year Sample"
						"Observations"
						"Mean of DV"
						"SD of DV"

						) )
			title("")
			nomtitles


		;

	#delimit cr



* END OF SPECIFICATIONS DO FILE
*------------------------------
