use "C:\Users\Tharun\Downloads\PLFS Data July 2023 to June 2024\DDI-IND-CSO-PLFS-2023-24 - Stata Files\Fully Merged.dta"
* --- Step 1.1: Calculate Weekly Wage - Activity 1 (Sum across 7 days) ---
gen double weekly_wage_act1 = 0
* Day 7 (Suffix 1)
replace weekly_wage_act1 = weekly_wage_act1 + b6q9_3pt1_perrv if inlist(b6q4_3pt1_perrv, "31", "71", "72")
* Day 6 (Suffix 2) - Correcting for status variable anomaly (b6q4_3pt2)
replace weekly_wage_act1 = weekly_wage_act1 + b6q9_3pt2_perrv if inlist(b6q4_3pt2_perrv, "31", "71", "72")
* Day 5 (Suffix 3)
replace weekly_wage_act1 = weekly_wage_act1 + b6q9_3pt3_perrv if inlist(b6q4_3pt3_perrv, "31", "71", "72")
* Day 4 (Suffix 4)
replace weekly_wage_act1 = weekly_wage_act1 + b6q9_3pt4_perv1 if inlist(b6q4_3pt4_perrv, "31", "71", "72")
* Day 3 (Suffix 5)
replace weekly_wage_act1 = weekly_wage_act1 + b6q9_3pt5_perv1 if inlist(b6q4_3pt5_perrv, "31", "71", "72")
* Day 2 (Suffix 6)
replace weekly_wage_act1 = weekly_wage_act1 + b6q9_3pt6_perv1 if inlist(b6q4_3pt6_perrv, "31", "71", "72")
* Day 1 (Suffix 7)
replace weekly_wage_act1 = weekly_wage_act1 + b6q9_3pt7_perv1 if inlist(b6q4_3pt7_perrv, "31", "71", "72")
* --- Step 1.2: Calculate Weekly Wage - Activity 2 (Sum across 7 days) ---
gen double weekly_wage_act2 = 0
* Day 7 (Suffix 1)
replace weekly_wage_act2 = weekly_wage_act2 + b6q9_act2_3pt1_perv1 if inlist(b6q4_act2_3pt1_perrv, "31", "71", "72")
* Day 6 (Suffix 2)
replace weekly_wage_act2 = weekly_wage_act2 + b6q9_act2_3pt2_perv1 if inlist(b6q4_act2_3pt2_perrv, "31", "71", "72")
* Day 5 (Suffix 3)
replace weekly_wage_act2 = weekly_wage_act2 + b6q9_act2_3pt3_perv1 if inlist(b6q4_act2_3pt3_perrv, "31", "71", "72")
* Day 4 (Suffix 4)
replace weekly_wage_act2 = weekly_wage_act2 + b6q9_act2_3pt4_perv1 if inlist(b6q4_act2_3pt4_perrv, "31", "71", "72")
* Day 3 (Suffix 5)
replace weekly_wage_act2 = weekly_wage_act2 + b6q9_act2_3pt5_perv1 if inlist(b6q4_act2_3pt5_perrv, 31, 71, 72)
* Day 2 (Suffix 6)
replace weekly_wage_act2 = weekly_wage_act2 + b6q9_act2_3pt6_perv1 if inlist(b6q4_act2_3pt6_perrv, "31", "71", "72")
* Day 1 (Suffix 7)
replace weekly_wage_act2 = weekly_wage_act2 + b6q9_act2_3pt7_perrv if inlist(b6q4_act2_3pt7_perrv, "31", "71", "72")
* --- Step 1.3: Total Monthly Earnings and Log Transformation ---
gen double total_monthly_earnings = (weekly_wage_act1 + weekly_wage_act2) * 4 + b6q9_perv1
* --- Age and Age Squared ---
rename b4q6_perv1 age
label var age "Age"
gen double age_sq = age^2
label var age_sq "Age Squared"
* --- Education ---
rename b4q10_perv1 education
label var education "No. of years in Formal Education"
gen double edu_sq = education^2
label var edu_sq "Education Squared"
* --- Urban Dummy (Urban=1, Rural=0) ---
* Sector: 1=Rural, 2=Urban
gen urban = (Sector == "2") if !missing(Sector)
label var urban "Urban (1=Urban, 0=Rural)"
* --- Gender Dummy (Female=1, Male=0) ---
* Gender (b4q5_perv1): 1=Male, 2=Female
gen female = (b4q5_perv1 == "2") if !missing(b4q5_perv1)
label var female "Female (1=Female, 0=Male)"
display _N
count if state_hhv1 == "29"
summarize total_monthly_earnings, detail
drop if total_monthly_earnings <= 0 | missing(total_monthly_earnings)
gen double ln_earnings = log(total_monthly_earnings)
label var ln_earnings "Ln(Total Monthly Earnings)"
display _N
count if state_hhv1 == "29"
summarize ln_earnings, detail
regress ln_earnings age_sq edu_sq urban female age education
keep if state_hhv1 == "29"
display _N
* Model 1: Earnings as a Function of Age and Education
regress total_monthly_earnings age education, robust
* Model 2: Earnings with Age, Education, and Gender
regress total_monthly_earnings age education female, robust
* Model 3: Earnings with Age, Education, and Sector
regress total_monthly_earnings age education urban, robust
* Model 4: Log Wages with Age and Education
regress ln_earnings age education, robust
* Model 5: Log Wages with Age, Education, and Gender
regress ln_earnings age education female, robust
* Model 6: Log Wages with Age, Education, and Sector
regress ln_earnings age education urban, robust
* Model 7: Log Wages with Age and Age² (Life-Cycle Hypothesis)
regress ln_earnings age age_sq, robust
* Model 8: Log Wages with Education and Education² (Gary Becker's Hypothesis)
regress ln_earnings education edu_sq, robust
* Model 9: Log Wages with Gender, Sector, and Interaction
regress ln_earnings i.female##i.urban, robust
margins female#urban
* Model 10: Log Wages with Age, Education, Gender, Sector, and Interaction
regress ln_earnings age education i.female##i.urban, robust
margins female#urban