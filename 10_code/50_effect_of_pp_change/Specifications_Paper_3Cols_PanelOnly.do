

* PAPER SPECIFICATIONS
*---------------------


* output folder
*--------------

cd "${output}"






* clear eststo
*-------------

_eststo clear




* specification 1
*----------------

local estimate = "est_1"
fvset base 2008 year
fvset base 190 voter_index  		// arbitrary

eststo `estimate':	xi:		areg ${dv1} ${iv1} ${iv2} ${iv3} ${controls_panel} i.year 			///
								, vce(cl ${cluster1})  absorb(${cluster1})

				summary_stats "`estimate'" ${dv1} ${cluster1}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"Full Panel": `estimate'
				estadd local indivfixed 	"\checkmark": `estimate'
				estadd local yearfixed 		"\checkmark": `estimate'
				estadd local raceyearfixed	"\checkmark": `estimate'
				estadd local countyfe		"": `estimate'
				estadd local controls 		"": `estimate'



					// coefficient estimates
					local beta 		= (_b[${iv1}]) * 100

						${closef}
						${openf} "${filename}_`estimate'.tex", write replace
						${writef} %7.1f (`beta')
						${closef}






* specification 2
*----------------

local estimate = "est_2"
fvset base 2008 year
fvset base 190 voter_index  		// arbitrary

eststo `estimate':	xi:		areg ${dv2} ${iv1} ${iv2} ${iv3} ${controls_panel} i.year 			///
								, vce(cl ${cluster1})  absorb(${cluster1})

				summary_stats "`estimate'" ${dv2} ${cluster1}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"Full Panel": `estimate'
				estadd local indivfixed 	"\checkmark": `estimate'
				estadd local yearfixed 		"\checkmark": `estimate'
				estadd local raceyearfixed	"\checkmark": `estimate'
				estadd local countyfe		"": `estimate'
				estadd local controls 		"": `estimate'

					// coefficient estimates
					local beta 		= (_b[${iv1}]) * 100

						${closef}
						${openf} "${filename}_`estimate'.tex", write replace
						${writef} %7.1f (`beta')
						${closef}



* specification 3
*----------------

local estimate = "est_3"
fvset base 2008 year
fvset base 190 voter_index  		// arbitrary

eststo `estimate':	xi:		areg ${dv3} ${iv1} ${iv2} ${iv3} ${controls_panel} i.year 			///
								, vce(cl ${cluster1})  absorb(${cluster1})

				summary_stats "`estimate'" ${dv3} ${cluster1}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"Full Panel": `estimate'
				estadd local indivfixed 	"\checkmark": `estimate'
				estadd local yearfixed 		"\checkmark": `estimate'
				estadd local raceyearfixed	"\checkmark": `estimate'
				estadd local countyfe		"": `estimate'
				estadd local controls 		"": `estimate'


					// coefficient estimates
					local beta 		= (_b[${iv1}]) * 100

						${closef}
						${openf} "${filename}_`estimate'.tex", write replace
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
			fragment keep(${iv1} ${iv2} ${iv3})


			stats(indivfixed yearfixed raceyearfixed sample N meandv stddv ,
				labels(	"Individual FE"
						"Year FE"
						"Race x Year FE"
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



		using "${filename}_wcontrols.tex",
			b(a2) label replace nogaps compress se(a2) bookt
			noconstant nodepvars star(* 0.1 ** 0.05 *** 0.01)
			fragment keep(${iv1 ${iv2} ${iv3}} ${controls_panel})


			stats(indivfixed yearfixed sample N meandv stddv ,
				labels(	"Individual FE"
						"Year FE"
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
