# To be Addressed

# Dtap - if too old, need to switch to a series that the person qualifies for

# CDC Question
# If a target dose is labeled "skip" do you take the next AAR and use that for then ext one?
#   The documentation says:
#     Skipped A target dose status that indicates no vaccine dose administered has met the goals of the target dose. Due to the patient's age and/or interval from a previous dose, the target dose does not need to be satisfied.
#   This seems to imply that the target dose conditional skip was evaluated after the rest of the other attributes (age, interval, etc) - However when evaluating 'satisfy target dose', the order of the evaluations has the target dose conditional skip being evaluated before age/interval


  # Why are the polio vaccines all '<forecastVaccineType>N</forecastVaccineType>'

# Still need clarification from CDC: TABLE 6-7 CONDITIONAL TYPE OF COMPLETED SERIES – IS THE CONDITION MET?
#   Also ask - if a patient has a conditional skip that is 'skipped' - does the target dose then be used for
#   the next target dose?

# Need HD to clarify -
#   Explain HepA vaccine schedule (0 - 12 months?)
#   Explain Pneummococal vaccine schedule
#   Explain how a 'catch up schedule' works
#   Hep A latest RECOMMENDED Interval (latestRecInt) 19 months + 4 weeks
#     - Is there such thing as a latest interval that it can no longer be
#     given or they have to restart?
#   Hep B latest RECOMMENDED interval (latestRecInt) 19 months + 4 weeks
#     - Is there such thing as a latest interval that it can no longer be
#     given or they have to restart?


#   TD/TDAP same group, DTAP in different vaccine group

# NEED TO INCLUDE MIN AGE TO START AND MAX AGE TO START INTO THE CHECK IF THE ANTIGENSERIES IS VALID FOR THE PATIENT
#   Pneumoccocal is not straightforward - there is max age/min age
# NEED TO INCLUDE IF THE DOSE WAS EXPIRED OR INVALID


# Need to have a better way of creating antigen administered records
# Should have vaccine info linked to antigen and vaccine_dose linked to vaccine_info schema wise


# Recurring Doses
# PAGE 38
# 6.	 This step determines if the current target dose (now the last target dose in the patient series) is a recurring
# dose. (This is a rare condition for Td and Flu as well as certain risk series.) A recurring dose may recur based
# on a time interval from the previous dose (i.e. a tetanus recurring dose every 10 years for adults) or based
# on a patient observation (i.e. a pertussis recurring dose with every pregnancy).
# a.	 If the target dose is defined to be a recurring dose, initialize a new target dose identical to the current
# target dose. The newly created target dose must now be the last element in the collection. Finally,
# iterate the collection to get this target dose and proceed to step 7.
# b.	 If the target dose is not defined to be a recurring dose, the evaluation process for this patient series
# ends. Any remaining antigen administered records should have their evaluation statuses set to
# “extraneous.”



# Testing on the evaluate antigen -
#   Not testing for all invalid patient series (intervals, if incomplete or complete but then finally immune)


# Dipheria Recuring dose #10 - no min age, every few years you need to get it
#   Need logic for recurring dose


# If the vaccine group/antigen is not evaluated at all (no eligible doses), return 'N/A'

# Recurring doses are currently not eligible to be eligible

# Have not included any sort of check to ensure the vaccine dose administered was valid by expiration or lot recals


# Implement interval type 'from_target_dose' for the interval evaluation

# Future dose contraindications
# Future dose evidence of immunity
#


# Report to CDC issues with the data (hep a and hepb formatting issues, 7 years/7 Years formatting issues), vaccine types spacing differences
# <condition>
# <conditionID>1</conditionID>
# <conditionType>Vaccine Count by Date</conditionType>
# <startDate>20150701</startDate>
# <endDate>20160630</endDate>
# <beginAge/>
# <endAge/>
# <interval/>
# <doseCount>0</doseCount>
# <doseType>Valid</doseType>
# <doseCountLogic>greater than</doseCountLogic>
# <vaccineTypes>15; 16; 88; 111; 135; 140; 141; 144; 149; 150; 151; 153; 155; 158; 161; 166</vaccineTypes>
# </condition>



# Varicella => If have disease =>


# Same page for the entire staff on why we need a phone number



# Responses from Jolene

# Need HD to clarify -
#   Explain HepA vaccine schedule (0 - 12 months?)

#     - Supposed to be given at age 1, 2nd 6 months later (on time)
#     - If not at age 1, next 6 months later
#       - Even with massive time in between, second dose
#       - 2 doses and good

#   Explain Pneummococal vaccine schedule
#     - On schedule: 2 months, 4 months, 6 months, then 12 months
#     - Catchup: 2 months (as early as 6 weeks)
#       -> 4 weeks if before 1st dose before 12 months
#       -> 8 weeks if first dose given at 12 months or older, or if current age is 24 through 59 months
#       -> No second dose needed if health and first dose given at 24 or older

#   Pneumoccocal is not straightforward - there is max age/min age
#     - After max age you no longer need to give it

#   Explain how a 'catch up schedule' works
#   Hep A latest RECOMMENDED Interval (latestRecInt) 19 months + 4 weeks
#     - Is there such thing as a latest interval that it can no longer be
#     given or they have to restart?
#       => Its recommended - never TOO much time passed between so you cant get a shot
#   Hep B latest RECOMMENDED interval (latestRecInt) 19 months + 4 weeks
#     - Is there such thing as a latest interval that it can no longer be
#     given or they have to restart?

#   Because of the different recommendations (school is 4)
#     - Most adults, if they are refugees, recomend 3 tetanus
#       - starts with TDAp
#       - 30 days another TD
#       - 6 months for another TD
#     - Kids
#       - Dtap (2 months to age of 6)
#       - Once they turn 7, they get TD or TDAp
#         - 7 year old comes in without anything before, hit em with a TDAp
#         - 7 with say 3 dtaps, hit them with a TD
#           - Want to make sure they have 2 - 3 pertussis, if not you will do a TDAP (7 year old with 1 - 2 dtap, hit em with tdap)

