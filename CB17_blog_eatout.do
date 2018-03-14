** Blog -- Women significantly less likely to go out to eat in Georgia
** CRRC Caucasus Barometer 2017, Georgia 
** March, 2017
///////////////////////////////////////////////////////////////////////////////

clear all
use "CB_2017_Georgia_17.11.17.dta" 

// recode variables

** Went to a restaurant?
recode q1_05 (0=0)(1=1)(else=.), gen(restau)
lab var restau "Went to a restaurant?"

** stratum
recode stratum(1=3)(2=2)(3=1), gen(stra)
lab var stra "Settlement type"

** gender
recode sex (1=1)(2=2), gen(female)
lab var female "Respondent's gender"
lab define gender 1 "Male" 2 "Female"
lab values female gender

** age groups
recode age (18/37=3)(38/57=2)(58/100=1), gen(agegr20)
lab var agegr20 "Age groups {1=58/100}"

** education
recode d3 (1/4=1)(5=2)(6/8=3)(else=.), gen(persedu)
lab var persedu "Highest level of education achieved"

gen edu=d2
mvdecode edu, mv(-9/-1)
lab var edu "Education in years"

recode d4 (1/5=0)(6/8=1)(else=.), gen(rfaedu)
recode d5 (1/5=0)(6/8=1)(else=.), gen(rmoedu)
gen paredu=.
replace paredu=2 if rfaedu==1|rmoedu==1
replace paredu=1 if rfaedu==0&rmoedu==0
lab var paredu "Any parent with higher education?"

** employment
recode j1 (1/4=0)(7/8=0)(5/6=1)(else=.), gen(emplsit)
lab var emplsit "Employed?"

gen empl=.
replace empl=3 if emplsit==1
replace empl=2 if emplsit==0&j3==1&j5==1
replace empl=1 if emplsit==0&(j3==-2|j3==-1|j3==0|j5==-2|j5==-1|j5==0)
lab var empl "Employment status"

** Current HH rung
gen currung10=c10
replace currung10=. if c10==-9|c10==-3|c10==-2|c10==-1
recode c10 (1/4=1)(5/6=2)(7/10=3)(else=.), gen(currung)
lab var currung "Current HH rung"
lab var currung10 "Current HH rung"

** income and expenditure
recode c6(-2/-1=1)(5/8=2)(4=3)(1/3=4)(else=.), gen(monytot)
recode c7(-2/-1=1)(5/8=2)(4=3)(1/3=4)(else=.), gen(spendmo)
recode j11(-2/-1=1)(5/8=2)(4=3)(1/3=4)(else=.), gen(persinc)
lab var persinc "Personal income"
lab var monytot "HH income"
lab var spendmo	"HH spending"
lab define mony 1 "DK/RA" 2 "Up to $250" 3 "$251-$400" 4 "More than $400"
lab val monytot mony
lab val spendmo mony
lab val persinc mony

///////////////////////////////////////////////////////////////////////////////

graph set window fontface "Times New Roman"

** survey settings
svyset psu [pweight=indwt], strata(substratum) fpc(npsuss) singleunit(certainty) || id, fpc(nhhpsu) || _n, fpc(nadhh)

*** Graph 2. Marginal effects of logit estimates

svyset psu [pweight=indwt], strata(substratum) fpc(npsuss) singleunit(certainty) || id, fpc(nhhpsu) || _n, fpc(nadhh)

qui: svy: logit restau i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo, or
qui: margins, dydx(*) post
est store m1

coefplot ///
(m1, label("") lpatt(solid)lwidth(none)lcol(ebblue)msym(d)mcol(ebblue)ciopts(lpatt(solid)lcol(ebblue))), ///
drop(_cons year) xscale() xline(0, lcolor(red) lwidth(thin) lpattern(dash)) ///
xtitle(Effects on Pr (went to a restaurant?)) levels(95) ///
baselevels graphregion(color(white)) ///
coeflabels(_cons="Constant" ///
1.stra="Rural" 2.stra="Other urban" 3.stra="Capital" ///
1.female="Male" 2.female="Female" ///
1.empl="No labor force" 2.empl="Unemplyed" 3.empl="Employed" ///
1.spendmo="Spending (DK/RA)" 2.spendmo="Spending < $251" 3.spendmo="Spending - $251 to $400" 4.spendmo="Spending > $400" /// 
age="Age" ///
edu="Education (years)" ///
currung10="Perceived rung", ///
wrap(27) notick labcolor(black*.8) labsize(medsmall) labgap(2)) /// 
title("During the last 6 months, did you go to a restaurant?" "Marginal effects", color(dknavy*.9) tstyle(size(mlarge)) span) ///
subtitle("95% Confidence Intervals", color(dknavy*.8) tstyle(size(msmall)) span) ///
note("CRRC Caucasus Barometer 2017, Georgia")

graph export "Graph_2.png", width(3000) replace 

** Graph 3. Marginal effects of age and education by gender

qui: svy: logit restau i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo, or
qui: margins female, at (age==(18(5)98)) vce(uncond)
marginsplot, name(a, replace) recastci(rcap) ciopts(color(ebblue*.5)) ///
title("", color(dknavy) tstyle(size(medium)) span) ///
subtitle("", color(dknavy) tstyle(size(medium)) span) /// 
graphregion(color(white)) ///
xlabel(18(20)98) xtitle("Age") ///
ylabel(0(.5)1) ytitle(Probability of going to a restaurant) ///
plot1opts(lpatt(solid) lwidth(thin) lcolor(ebblue) mcolor(ebblue) msym(d) mcol(ebblue))

////
qui: svy: logit restau i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo, or
qui: margins female, at (edu==(4(2)20)) vce(uncond)
marginsplot, name(b, replace) recastci(rcap) ciopts(color(ebblue*.5)) ///
title("", color(dknavy) tstyle(size(medium)) span) ///
subtitle("", color(dknavy) tstyle(size(medium)) span) /// 
graphregion(color(white)) ///
xlabel(4(4)20) xtitle("Education (years)") ///
ylabel(0(.5)1) ytitle("") ///
xtitle(Years of education) note() ///
plot1opts(lpatt(solid) lwidth(thin) lcolor(ebblue) mcolor(ebblue) msym(d) mcol(ebblue))

grc1leg a b, ///
title("During the last 6 months, did you go to a restaurant?" "Effects of age and years of education by Gender", color(dknavy*.9) tstyle(size(mlarge)) span) ///
subtitle("Predicted probabilities, 95% Confidence Intervals", color(dknavy*.8) tstyle(size(msmall)) span) legendfrom(a) ///
graphregion(color(white)) ///
note("CRRC Caucasus Barometer 2017, Georgia")

graph export "Graph_3.png", width(3000) replace 

// Graph 4. Marginal effects of employment and spending by gender

qui: svy: logit restau i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo, or
qui: margins female, at (empl==(1 2 3)) vce(uncond)
marginsplot, name(c, replace) recastci(rcap) ciopts(color(ebblue*.9)) ///
title("", color(dknavy) tstyle(size(medium)) span) ///
subtitle("", color(dknavy) tstyle(size(medium)) span) /// 
graphregion(color(white)) ///
xdim(empl) xlabel(1 "No labor force" 2 "Unemployed" 3 "Employed") xtitle("Employment status") xscale(range(0.8 2)) ///
recast(scatter) ///
ylabel(0(.5)1) ytitle(Probability of going to a restaurant) ///
plot1opts(lpatt(solid) lwidth(medium) lcolor(ebbblue) mcolor(ebbblue) msym(d) mcol(ebblue)) 

/////
gen spendmo1=5-spendmo
qui: svy: logit restau i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo1, or
qui: margins female, at (spendmo==(1 2 3 4)) vce(uncond)
marginsplot, name(d, replace) recastci(rcap) ciopts(color(ebblue*.9)) ///
title("", color(dknavy) tstyle(size(large)) span) ///
subtitle("", color(dknavy) tstyle(size(medium)) span) /// 
graphregion(color(white)) ///
xdim(spendmo1) xlabel(4 "DK/RA" 3 "< $251" 2 "$251 to $400" 1 "> $400") xtitle("Household spending") xscale(range(0.8 2)) ///
recast(scatter) ///
ylabel(0(.5)1) ytitle("") ///
plot1opts(lpatt(solid) lwidth(medium) lcolor(ebbblue) mcolor(ebbblue) msym(d) mcol(ebblue))

grc1leg c d, ///
title("During the last 6 months, did you go to a restaurant?" "Effects of employment status and household spending by Gender ", color(dknavy*.9) tstyle(size(mlarge)) span) ///
subtitle("Predicted probabilities, 95% Confidence Intervals", color(dknavy*.8) tstyle(size(msmall)) span) legendfrom(c) ///
graphregion(color(white)) ///
note("CRRC Caucasus Barometer 2017, Georgia")

graph export "Graph_4.png", width(3000) replace 

// Graph 5. Marginal effects of HH conditions and settlement type

qui: svy: logit restau i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo, or
qui: margins female, at (currung10==(1(1)10)) vce(uncond)
marginsplot, name(e, replace) recastci(rcap) ciopts(color(ebblue*.5)) ///
title("", color(dknavy) tstyle(size(medium)) span) ///
subtitle("", color(dknavy) tstyle(size(medium)) span) /// 
graphregion(color(white)) ///
xlabel(1(2)10) xtitle("Perceived household rung") ///
ylabel(0(.5)1) ytitle(Probability of going to a restaurant) ///
plot1opts(lpatt(solid) lwidth(thin) lcolor(ebblue) mcolor(ebblue) msym(d) mcol(ebblue))

///////////////////////////////////

qui: svy: logit restau i.stra i.female i.empl c.age c.edu c.currung10 i.spendmo, or
qui: margins female, at (stra==(1 2 3)) vce(uncond)
marginsplot, name(f, replace) recastci(rcap) ciopts(color(ebblue*.9)) ///
title("", color(dknavy) tstyle(size(large)) span) ///
subtitle("", color(dknavy) tstyle(size(medium)) span) /// 
graphregion(color(white)) ///
xdim(stra) xlabel(1 "Rural" 2 "Other urban" 3 "Capital") xtitle("Settlement type") xscale(range(0.8 2)) ///
recast(scatter) ///
ylabel(0(.5)1) ytitle("") ///
plot1opts(lpatt(solid) lwidth(medium) lcolor(ebbblue) mcolor(ebbblue) msym(d) mcol(ebblue)) 

grc1leg e f, ///
title("During the last 6 months, did you go to a restaurant?" "Effects of settlement type and HH rung by Gender ", color(dknavy*.9) tstyle(size(mlarge)) span) ///
subtitle("Predicted probabilities, 95% Confidence Intervals", color(dknavy*.8) tstyle(size(msmall)) span)  legendfrom(e) ///
graphregion(color(white)) ///
note("CRRC Caucasus Barometer 2017, Georgia")

graph export "Graph_5.png", width(3000) replace 

*******************************************************************************

// Interactions with gender

svyset psu [pweight=indwt], strata(substratum) fpc(npsuss) singleunit(certainty) || id, fpc(nhhpsu) || _n, fpc(nadhh)

svy: logit restau i.stra##i.female i.empl c.age c.edu c.currung10 i.spendmo, or
svy: logit restau i.stra i.empl##i.female c.age c.edu c.currung10 i.spendmo, or
svy: logit restau i.stra i.empl c.age##i.female c.edu c.currung10 i.spendmo, or
svy: logit restau i.stra i.empl c.age c.edu##i.female c.currung10 i.spendmo, or
svy: logit restau i.stra i.empl c.age c.edu c.currung10##i.female i.spendmo, or
svy: logit restau i.stra i.empl c.age c.edu c.currung10 i.spendmo##i.female, or
