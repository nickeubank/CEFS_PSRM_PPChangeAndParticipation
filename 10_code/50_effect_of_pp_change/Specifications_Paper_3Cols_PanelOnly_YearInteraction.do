

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

eststo `estimate':	xi:		areg ${dv1} ${iv1}  ${controls_crosssection} year_2016 			///
								, vce(cl ${cluster2})  absorb(${absorb})





* specification 2
*----------------

local estimate = "est_2"
fvset base 2008 year
fvset base 190 voter_index  		// arbitrary

eststo `estimate':	xi:		areg ${dv2} ${iv1}  ${controls_crosssection} year_2016 			///
								, vce(cl ${cluster2})  absorb(${absorb})





* specification 3
*----------------

local estimate = "est_3"
fvset base 2008 year
fvset base 190 voter_index  		// arbitrary

eststo `estimate':	xi:		areg ${dv3} ${iv1}  ${controls_crosssection} year_2016 			///
								, vce(cl ${cluster2})  absorb(${absorb})






* END OF SPECIFICATIONS DO FILE
*------------------------------
