

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

eststo `estimate':	xi:		areg ${dv1} ${iv1} ${iv2}  ${controls_crosssection} ///
									if  ${year1}, vce(cl ${cluster2}) a(${absorb})

				summary_stats "`estimate'" ${dv1} ${absorb}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2012": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'

								// coefficient estimates
					local beta 		= (_b[${iv1}]) * 100

						${closef}
						${openf} "${filename}_`estimate'_${iv2}.tex", write replace
						${writef} %7.1f (`beta')
						${closef}




* specification 2
*----------------

local estimate = "est_2"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv2} ${iv1} ${iv2}  ${controls_crosssection} ///
									if  ${year1}, vce(cl ${cluster2}) a(${absorb})

				summary_stats "`estimate'" ${dv1} ${absorb}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2012": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'

					// coefficient estimates
					local beta 		= (_b[${iv1}]) * 100

						${closef}
						${openf} "${filename}_`estimate'_${iv2}.tex", write replace
						${writef} %7.1f (`beta')
						${closef}



* specification 3
*----------------

local estimate = "est_3"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv3} ${iv1} ${iv2}  ${controls_crosssection} ///
									if  ${year1}, vce(cl ${cluster2}) a(${absorb})

				summary_stats "`estimate'" ${dv2} ${absorb}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2012": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local yearfixed 		"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'

					// coefficient estimates
					local beta 		= (_b[${iv1}]) * 100

						${closef}
						${openf} "${filename}_`estimate'_${iv2}.tex", write replace
						${writef} %7.1f (`beta')
						${closef}






* output the regressions
*-----------------------

	cd "${output}"

	#delimit;

	esttab

		est_1
		est_2
		est_3




		using "${filename}.tex",
			b(a2) label replace nogaps compress se(a2) bookt
			noconstant nodepvars star(* 0.1 ** 0.05 *** 0.01)
			fragment keep(${iv1} ${iv2})


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


	cd "${output}";


	esttab

		est_1
		est_2
		est_3




		using "${filename}_wcontrols.tex",
			b(a2) label replace nogaps compress se(a2) bookt
			noconstant nodepvars star(* 0.1 ** 0.05 *** 0.01)
			fragment keep(${iv1} ${iv2} ${controls_crosssection})


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





* END OF SPECIFICATIONS DO FILE
*------------------------------
