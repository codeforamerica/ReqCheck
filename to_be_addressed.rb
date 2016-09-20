# To be Addressed


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
