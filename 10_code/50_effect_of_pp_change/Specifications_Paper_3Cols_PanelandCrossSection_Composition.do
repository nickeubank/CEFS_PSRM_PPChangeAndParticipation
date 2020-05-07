

* PAPER SPECIFICATIONS
*---------------------



* clear eststo
*-------------

_eststo clear




* specification 1
*----------------

local estimate = "est_1"
fvset base 2008 year
fvset base 190 voter_index  		// arbitrary

eststo `estimate':	xi:		areg ${dv1} ${iv1}  ${controls_panel}  ${interaction_fe} ${controls_composition} i.year 			///
								if party != 3, vce(cl ${cluster1})  absorb(${absorb})


				summary_stats "`estimate'" ${dv1} ${absorb}

				* Other extras
				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"Full Panel": `estimate'
				estadd local yearfixed		"\checkmark": `estimate'
				estadd local countyyear		"\checkmark": `estimate'
				estadd local indivfixed 	"\checkmark": `estimate'
				estadd local raceyearfixed	"\checkmark": `estimate'
				estadd local countyfe		"": `estimate'
				estadd local controls 		"": `estimate'

                test  pp_has_changed_x_party_rep pp_has_changed_x_party_una
                estadd scalar jointsig_party `r(p)': `estimate'






* specification 2
*----------------

local estimate = "est_2"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv1} ${iv1} ${controls_crosssection_comp} ///
									if  ${year1} & party != 3, vce(cl ${cluster2}) a(${cluster2})

				summary_stats "`estimate'" ${dv1} ${cluster2}

				estadd scalar clusters = e(N_clust): `estimate'

				estadd local sample			"2012": `estimate'
				estadd local yearfixed		"": `estimate'
				estadd local indivfixed 	"": `estimate'
				estadd local raceyearfixed	"": `estimate'
				estadd local countyyear		"": `estimate'
				estadd local countyfe		"\checkmark": `estimate'
				estadd local controls 		"\checkmark": `estimate'

				test  pp_has_changed_x_party_rep pp_has_changed_x_party_una
                estadd scalar jointsig_party `r(p)': `estimate'




* specification 3
*----------------

local estimate = "est_3"
fvset base 37001 county_fips  		// arbitrary

eststo `estimate':	xi:		areg ${dv1} ${iv1} ${controls_crosssection_comp} ///
							if  ${year2} & party != 3, vce(cl ${cluster2}) a(${cluster2})

		summary_stats "`estimate'" ${dv1} ${cluster2}

		estadd scalar clusters = e(N_clust): `estimate'

		estadd local sample			"2016": `estimate'
		estadd local yearfixed		"": `estimate'
		estadd local indivfixed 	"": `estimate'
		estadd local raceyearfixed	"": `estimate'
		estadd local countyyear		"": `estimate'
		estadd local countyfe		"\checkmark": `estimate'
		estadd local controls 		"\checkmark": `estimate'


test  pp_has_changed_x_party_rep pp_has_changed_x_party_una
estadd scalar jointsig_party `r(p)': `estimate'





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
			fragment keep(${iv1})


			stats(indivfixed yearfixed countyyear raceyearfixed countyfe controls sample N meandv stddv jointsig_party,
				labels(	"Individual FE"
						"Year FE"
						"County x Year FE"
						"Race x Year FE"
						"County FE"
						"Controls"
						"Year Sample"
						"Observations"
						"Mean of DV"
						"SD of DV"
                        "Party Joint Sig"

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
			fragment keep(${iv1} ${controls_panel} ${controls_composition} ${controls_crosssection_comp}  )


			stats(indivfixed yearfixed countyyear countyfe sample N meandv stddv jointsig_party ,
				labels(	"Individual FE"
						"Year FE"
						"County x Year FE"
						"County FE"
						"Year Sample"
						"Observations"
						"Mean of DV"
						"SD of DV"
                        "Party Joint Sig"

						) )
			title("")
			nomtitles


		;

	#delimit cr





* END OF SPECIFICATIONS DO FILE
*------------------------------
