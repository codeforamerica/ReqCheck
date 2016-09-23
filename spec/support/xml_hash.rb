

module XMLHash
  SAMPLEDIPHTHERIA = {
    "antigenSupportingData" => {
        "immunity" => nil, "series" => {
            "seriesName" => "Diphtheria Standard Series", "targetDisease" => "Diphtheria", "vaccineGroup" => "DTaP/Tdap/Td", "selectBest" => {
                "defaultSeries" => "Yes", "productPath" => "No", "seriesPreference" => "1", "minAgeToStart" => "n/a", "maxAgeToStart" => "n/a"
            }, "seriesDose" => [{
                "doseNumber" => "Dose 1", "age" => {
                    "absMinAge" => "6 weeks - 4 days", "minAge" => "6 weeks", "earliestRecAge" => "2 months", "latestRecAge" => "3 months + 4 weeks", "maxAge" => nil
                }, "interval" => nil, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "INFANRIX", "mvx" => "SKB", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "TRIPEDIA", "mvx" => "PMC", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks", "endAge" => "5 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required for those 7 years or older", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Age", "startDate" => nil, "endDate" => nil, "beginAge" => "7 years", "endAge" => nil, "interval" => nil, "doseCount" => nil, "doseType" => nil, "doseCountLogic" => nil, "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has received 6 or more total doses to date", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => nil, "interval" => nil, "doseCount" => "5", "doseType" => "Total", "doseCountLogic" => "greater than", "vaccineTypes" => "01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146"
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 2", "age" => {
                    "absMinAge" => "10 weeks - 4 days", "minAge" => "10 weeks", "earliestRecAge" => "4 months", "latestRecAge" => "5 months + 4 weeks", "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "4 weeks - 4 days", "minInt" => "4 weeks", "earliestRecInt" => "8 weeks", "latestRecInt" => "13 weeks", "intervalPriority" => nil
                }, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "INFANRIX", "mvx" => "SKB", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "TRIPEDIA", "mvx" => "PMC", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks", "endAge" => "5 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required for those 7 years or older", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Age", "startDate" => nil, "endDate" => nil, "beginAge" => "7 years", "endAge" => nil, "interval" => nil, "doseCount" => nil, "doseType" => nil, "doseCountLogic" => nil, "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has received 6 or more total doses to date", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => nil, "interval" => nil, "doseCount" => "5", "doseType" => "Total", "doseCountLogic" => "greater than", "vaccineTypes" => "01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146"
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 3", "age" => {
                    "absMinAge" => "14 weeks - 4 days", "minAge" => "14 weeks", "earliestRecAge" => "6 months", "latestRecAge" => "7 months + 4 weeks", "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "4 weeks - 4 days", "minInt" => "4 weeks", "earliestRecInt" => "8 weeks", "latestRecInt" => "13 weeks", "intervalPriority" => nil
                }, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "INFANRIX", "mvx" => "SKB", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "TRIPEDIA", "mvx" => "PMC", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks", "endAge" => "5 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required for those 7 years or older", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Age", "startDate" => nil, "endDate" => nil, "beginAge" => "7 years", "endAge" => nil, "interval" => nil, "doseCount" => nil, "doseType" => nil, "doseCountLogic" => nil, "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has received 6 or more total doses to date", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => nil, "interval" => nil, "doseCount" => "5", "doseType" => "Total", "doseCountLogic" => "greater than", "vaccineTypes" => "01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146"
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 4", "age" => {
                    "absMinAge" => "12 months - 4 days", "minAge" => "12 months", "earliestRecAge" => "15 months", "latestRecAge" => "19 months + 4 weeks", "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "6 months - 4 days", "minInt" => "6 months", "earliestRecInt" => "6 months", "latestRecInt" => "13 months + 4 weeks", "intervalPriority" => nil
                }, "allowableInterval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "absMinInt" => "4 months"
                }, "preferableVaccine" => [{
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "INFANRIX", "mvx" => "SKB", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "TRIPEDIA", "mvx" => "PMC", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks", "endAge" => "5 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult", "cvx" => "138", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult Unspecified Formulation", "cvx" => "139", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required for those 4 years or older", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Age", "startDate" => nil, "endDate" => nil, "beginAge" => "4 years", "endAge" => nil, "interval" => nil, "doseCount" => nil, "doseType" => nil, "doseCountLogic" => nil, "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has received 6 or more total doses to date", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => nil, "interval" => nil, "doseCount" => "5", "doseType" => "Total", "doseCountLogic" => "greater than", "vaccineTypes" => "01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146"
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 5", "age" => {
                    "absMinAge" => "4 years - 4 days", "minAge" => "4 years", "earliestRecAge" => "4 years", "latestRecAge" => "7 years", "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "6 months - 4 days", "minInt" => "6 months", "earliestRecInt" => "3 years", "latestRecInt" => "4 years + 4 weeks", "intervalPriority" => nil
                }, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "INFANRIX", "mvx" => "SKB", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => "TRIPEDIA", "mvx" => "PMC", "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "4 years", "endAge" => "7 years", "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult", "cvx" => "138", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult Unspecified Formulation", "cvx" => "139", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required for those 7 years or older", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Age", "startDate" => nil, "endDate" => nil, "beginAge" => "7 years", "endAge" => nil, "interval" => nil, "doseCount" => nil, "doseType" => nil, "doseCountLogic" => nil, "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has received 6 or more total doses to date", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => nil, "interval" => nil, "doseCount" => "5", "doseType" => "Total", "doseCountLogic" => "greater than", "vaccineTypes" => "01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146"
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 6", "age" => {
                    "absMinAge" => "7 years", "minAge" => "7 Years", "earliestRecAge" => "7 Years", "latestRecAge" => "7 Years", "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "4 weeks - 4 days", "minInt" => "4 weeks", "earliestRecInt" => "4 weeks", "latestRecInt" => "4 weeks", "intervalPriority" => nil
                }, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult", "cvx" => "138", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult Unspecified Formulation", "cvx" => "139", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required if the patient has received 2 or more doses before the age of 7 years", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => "7 years", "interval" => nil, "doseCount" => "1", "doseType" => "Valid", "doseCountLogic" => "greater than", "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has 1 or more doses between the ages of 1 and 7 years", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "1 years", "endAge" => "7 years", "interval" => nil, "doseCount" => "0", "doseType" => "Valid", "doseCountLogic" => "greater than", "vaccineTypes" => nil
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 7", "age" => {
                    "absMinAge" => "7 years", "minAge" => "7 Years", "earliestRecAge" => "7 Years", "latestRecAge" => "7 Years", "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "4 weeks - 4 days", "minInt" => "4 weeks", "earliestRecInt" => "4 weeks", "latestRecInt" => "4 weeks", "intervalPriority" => nil
                }, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult", "cvx" => "138", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult Unspecified Formulation", "cvx" => "139", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required if the patient has 3 or more doses before the age of 7 years", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => "7 years", "interval" => nil, "doseCount" => "2", "doseType" => "Valid", "doseCountLogic" => "greater than", "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has received 2 or more doses between the ages of 1 and 7 years", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "1 years", "endAge" => "7 years", "interval" => nil, "doseCount" => "1", "doseType" => "Valid", "doseCountLogic" => "greater than", "vaccineTypes" => nil
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 8", "age" => {
                    "absMinAge" => "7 years", "minAge" => "7 Years", "earliestRecAge" => "7 Years", "latestRecAge" => "7 Years", "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "6 months - 4 days", "minInt" => "6 months", "earliestRecInt" => "6 months", "latestRecInt" => "6 months", "intervalPriority" => nil
                }, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult", "cvx" => "138", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult Unspecified Formulation", "cvx" => "139", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "OR", "set" => [{
                        "setID" => "1", "setDescription" => "Dose is not required if the patient has received 4 or more doses before the age of 7 years", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "6 weeks - 4 days", "endAge" => "7 years", "interval" => nil, "doseCount" => "3", "doseType" => "Valid", "doseCountLogic" => "greater than", "vaccineTypes" => nil
                        }
                    }, {
                        "setID" => "2", "setDescription" => "Dose is not required if the patient has received 3 or more doses between the ages of 1 and 7 years", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "1 years", "endAge" => "7 years", "interval" => nil, "doseCount" => "2", "doseType" => "Valid", "doseCountLogic" => "greater than", "vaccineTypes" => nil
                        }
                    }]
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 9", "age" => {
                    "absMinAge" => "7 years", "minAge" => "11 Years", "earliestRecAge" => "11 Years", "latestRecAge" => "13 Years", "maxAge" => nil
                }, "interval" => nil, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "DTP", "cvx" => "01", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP", "cvx" => "20", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib", "cvx" => "22", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DT", "cvx" => "28", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-Hib", "cvx" => "50", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTP-Hib-HepB", "cvx" => "102", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, 5 pertussis antigens", "cvx" => "106", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP, Unspecified Formulation", "cvx" => "107", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-HepB-IPV", "cvx" => "110", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-Hib-IPV", "cvx" => "120", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV", "cvx" => "130", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB,historical", "cvx" => "132", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }, {
                    "vaccineType" => "Td - Adult", "cvx" => "138", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult Unspecified Formulation", "cvx" => "139", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "DTaP-IPV-Hib-HepB", "cvx" => "146", "beginAge" => "6 weeks - 4 days", "endAge" => "19 years"
                }], "conditionalSkip" => {
                    "setLogic" => "n/a", "set" => {
                        "setID" => "1", "setDescription" => "Dose is not required if the patient has received at least one dose after the age of 7 years", "conditionLogic" => nil, "condition" => {
                            "conditionID" => "1", "conditionType" => "Vaccine Count by Age", "startDate" => nil, "endDate" => nil, "beginAge" => "7 years", "endAge" => nil, "interval" => nil, "doseCount" => "0", "doseType" => "Valid", "doseCountLogic" => "greater than", "vaccineTypes" => nil
                        }
                    }
                }, "recurringDose" => "No", "seasonalRecommendation" => nil, "requiredGender" => nil
            }, {
                "doseNumber" => "Dose 10", "age" => {
                    "absMinAge" => nil, "minAge" => nil, "earliestRecAge" => nil, "latestRecAge" => nil, "maxAge" => nil
                }, "interval" => {
                    "fromPrevious" => "Y", "fromTargetDose" => nil, "fromMostRecent" => nil, "absMinInt" => "2 years", "minInt" => "5 years", "earliestRecInt" => "10 years", "latestRecInt" => "10 years + 4 weeks", "intervalPriority" => nil
                }, "allowableInterval" => nil, "preferableVaccine" => [{
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "7 years", "endAge" => nil, "tradeName" => nil, "mvx" => nil, "volume" => "0.5", "forecastVaccineType" => "N"
                }], "allowableVaccine" => [{
                    "vaccineType" => "Td - Adult Adsorbed", "cvx" => "09", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td p-free", "cvx" => "113", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Tdap", "cvx" => "115", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult", "cvx" => "138", "beginAge" => "12 months - 4 days", "endAge" => nil
                }, {
                    "vaccineType" => "Td - Adult Unspecified Formulation", "cvx" => "139", "beginAge" => "12 months - 4 days", "endAge" => nil
                }], "conditionalSkip" => nil, "recurringDose" => "Yes", "seasonalRecommendation" => nil, "requiredGender" => nil
            }]
        }
    }
  }
  SAMPLEPOLIO = {
    "antigenSupportingData"=>
      {"immunity"=>"\n    ",
       "series"=>
        [{"seriesName"=>"Polio - All IPV - 4 Dose",
          "targetDisease"=>"Polio",
          "vaccineGroup"=>"Polio",
          "selectBest"=>
           {"defaultSeries"=>"Yes",
            "productPath"=>"Yes",
            "seriesPreference"=>"1",
            "minAgeToStart"=>"n/a",
            "maxAgeToStart"=>"n/a"},
          "seriesDose"=>
           [{"doseNumber"=>"Dose 1",
             "age"=>
              {"absMinAge"=>"6 weeks - 4 days",
               "minAge"=>"6 weeks",
               "earliestRecAge"=>"2 months",
               "latestRecAge"=>"3 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>nil,
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 2",
             "age"=>
              {"absMinAge"=>"10 weeks - 4 days",
               "minAge"=>"10 weeks",
               "earliestRecAge"=>"4 months",
               "latestRecAge"=>"5 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"4 weeks - 4 days",
               "minInt"=>"4 weeks",
               "earliestRecInt"=>"8 weeks",
               "latestRecInt"=>"13 weeks",
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 3",
             "age"=>
              {"absMinAge"=>"14 weeks - 4 days",
               "minAge"=>"14 weeks",
               "earliestRecAge"=>"6 months",
               "latestRecAge"=>"19 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"4 weeks - 4 days",
               "minInt"=>"4 weeks",
               "earliestRecInt"=>"8 weeks",
               "latestRecInt"=>"15 months + 4 weeks",
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>
              {"setLogic"=>"n/a",
               "set"=>
                {"setID"=>"1",
                 "setDescription"=>
                  "Dose is not required for those 4 years or older when the interval from the last dose is 6 months",
                 "conditionLogic"=>"AND",
                 "condition"=>
                  [{"conditionID"=>"1",
                    "conditionType"=>"Age",
                    "startDate"=>nil,
                    "endDate"=>nil,
                    "beginAge"=>"4 years - 4 days",
                    "endAge"=>nil,
                    "interval"=>nil,
                    "doseCount"=>nil,
                    "doseType"=>nil,
                    "doseCountLogic"=>nil,
                    "vaccineTypes"=>nil},
                   {"conditionID"=>"2",
                    "conditionType"=>"Interval",
                    "startDate"=>nil,
                    "endDate"=>nil,
                    "beginAge"=>nil,
                    "endAge"=>nil,
                    "interval"=>"6 months - 4 days",
                    "doseCount"=>nil,
                    "doseType"=>nil,
                    "doseCountLogic"=>nil,
                    "vaccineTypes"=>nil}]}},
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 4",
             "age"=>
              {"absMinAge"=>"4 years - 4 days",
               "minAge"=>"4 years",
               "earliestRecAge"=>"4 years",
               "latestRecAge"=>"7 years + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"6 months - 4 days",
               "minInt"=>"6 months",
               "earliestRecInt"=>"3 years",
               "latestRecInt"=>"6 years + 4 weeks",
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"4 years",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil}]},
         {"seriesName"=>"Polio IPV/OPV Mixed 4 Dose",
          "targetDisease"=>"Polio",
          "vaccineGroup"=>"Polio",
          "selectBest"=>
           {"defaultSeries"=>"No",
            "productPath"=>"No",
            "seriesPreference"=>"2",
            "minAgeToStart"=>"n/a",
            "maxAgeToStart"=>"n/a"},
          "seriesDose"=>
           [{"doseNumber"=>"Dose 1",
             "age"=>
              {"absMinAge"=>"6 weeks - 4 days",
               "minAge"=>"6 weeks",
               "earliestRecAge"=>"2 months",
               "latestRecAge"=>"3 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>nil,
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"OPV",
                "cvx"=>"02",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"Polio, Unspecified Formulation",
                "cvx"=>"89",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 2",
             "age"=>
              {"absMinAge"=>"10 weeks - 4 days",
               "minAge"=>"10 weeks",
               "earliestRecAge"=>"4 months",
               "latestRecAge"=>"5 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"4 weeks - 4 days",
               "minInt"=>"4 weeks",
               "earliestRecInt"=>"8 weeks",
               "latestRecInt"=>"13 weeks",
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"OPV",
                "cvx"=>"02",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"Polio, Unspecified Formulation",
                "cvx"=>"89",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 3",
             "age"=>
              {"absMinAge"=>"14 weeks - 4 days",
               "minAge"=>"14 weeks",
               "earliestRecAge"=>"6 months",
               "latestRecAge"=>"19 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"4 weeks - 4 days",
               "minInt"=>"4 weeks",
               "earliestRecInt"=>"8 weeks",
               "latestRecInt"=>"15 months + 4 weeks",
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"OPV",
                "cvx"=>"02",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"Polio, Unspecified Formulation",
                "cvx"=>"89",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 4",
             "age"=>
              {"absMinAge"=>"4 years - 4 days",
               "minAge"=>"4 years",
               "earliestRecAge"=>"4 years",
               "latestRecAge"=>"7 years + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"6 months - 4 days",
               "minInt"=>"6 months",
               "earliestRecInt"=>"3 years",
               "latestRecInt"=>"6 years + 4 weeks",
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              [{"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks",
                "endAge"=>nil,
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks",
                "endAge"=>"5 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"4 years",
                "endAge"=>"7 years",
                "tradeName"=>nil,
                "mvx"=>nil,
                "volume"=>"0.5",
                "forecastVaccineType"=>"N"}],
             "allowableVaccine"=>
              [{"vaccineType"=>"OPV",
                "cvx"=>"02",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"IPV",
                "cvx"=>"10",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"Polio, Unspecified Formulation",
                "cvx"=>"89",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-HepB-IPV",
                "cvx"=>"110",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-Hib-IPV",
                "cvx"=>"120",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV",
                "cvx"=>"130",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB, Historical",
                "cvx"=>"132",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil},
               {"vaccineType"=>"DTaP-IPV-Hib-HepB",
                "cvx"=>"146",
                "beginAge"=>"6 weeks - 4 days",
                "endAge"=>nil}],
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil}]},
         {"seriesName"=>"Polio - All OPV - 4 Dose",
          "targetDisease"=>"Polio",
          "vaccineGroup"=>"Polio",
          "selectBest"=>
           {"defaultSeries"=>"No",
            "productPath"=>"Yes",
            "seriesPreference"=>"3",
            "minAgeToStart"=>"n/a",
            "maxAgeToStart"=>"n/a"},
          "seriesDose"=>
           [{"doseNumber"=>"Dose 1",
             "age"=>
              {"absMinAge"=>"6 weeks - 4 days",
               "minAge"=>"6 weeks",
               "earliestRecAge"=>"2 months",
               "latestRecAge"=>"3 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>nil,
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks",
               "endAge"=>nil,
               "tradeName"=>nil,
               "mvx"=>nil,
               "volume"=>"0.5",
               "forecastVaccineType"=>"N"},
             "allowableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks - 4 days",
               "endAge"=>nil},
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 2",
             "age"=>
              {"absMinAge"=>"10 weeks - 4 days",
               "minAge"=>"10 weeks",
               "earliestRecAge"=>"4 months",
               "latestRecAge"=>"5 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"4 weeks - 4 days",
               "minInt"=>"4 weeks",
               "earliestRecInt"=>nil,
               "latestRecInt"=>nil,
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks",
               "endAge"=>nil,
               "tradeName"=>nil,
               "mvx"=>nil,
               "volume"=>"0.5",
               "forecastVaccineType"=>"N"},
             "allowableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks - 4 days",
               "endAge"=>nil},
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 3",
             "age"=>
              {"absMinAge"=>"14 weeks - 4 days",
               "minAge"=>"14 weeks",
               "earliestRecAge"=>"6 months",
               "latestRecAge"=>"19 months + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"4 weeks - 4 days",
               "minInt"=>"4 weeks",
               "earliestRecInt"=>nil,
               "latestRecInt"=>nil,
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks",
               "endAge"=>nil,
               "tradeName"=>nil,
               "mvx"=>nil,
               "volume"=>"0.5",
               "forecastVaccineType"=>"N"},
             "allowableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks - 4 days",
               "endAge"=>nil},
             "conditionalSkip"=>
              {"setLogic"=>"n/a",
               "set"=>
                {"setID"=>"1",
                 "setDescription"=>
                  "Dose is not required for those 4 years or older when the interval from the last dose is 6 months",
                 "conditionLogic"=>"AND",
                 "condition"=>
                  [{"conditionID"=>"1",
                    "conditionType"=>"Age",
                    "startDate"=>nil,
                    "endDate"=>nil,
                    "beginAge"=>"4 years - 4 days",
                    "endAge"=>nil,
                    "interval"=>nil,
                    "doseCount"=>nil,
                    "doseType"=>nil,
                    "doseCountLogic"=>nil,
                    "vaccineTypes"=>nil},
                   {"conditionID"=>"2",
                    "conditionType"=>"Interval",
                    "startDate"=>nil,
                    "endDate"=>nil,
                    "beginAge"=>nil,
                    "endAge"=>nil,
                    "interval"=>"6 months - 4 days",
                    "doseCount"=>nil,
                    "doseType"=>nil,
                    "doseCountLogic"=>nil,
                    "vaccineTypes"=>nil}]}},
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil},
            {"doseNumber"=>"Dose 4",
             "age"=>
              {"absMinAge"=>"4 years - 4 days",
               "minAge"=>"4 years",
               "earliestRecAge"=>"4 years",
               "latestRecAge"=>"7 years + 4 weeks",
               "maxAge"=>"18 years"},
             "interval"=>
              {"fromPrevious"=>"Y",
               "fromTargetDose"=>nil,
               "fromMostRecent"=>nil,
               "absMinInt"=>"4 weeks - 4 days",
               "minInt"=>"4 weeks",
               "earliestRecInt"=>nil,
               "latestRecInt"=>nil,
               "intervalPriority"=>nil},
             "allowableInterval"=>nil,
             "preferableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks",
               "endAge"=>nil,
               "tradeName"=>nil,
               "mvx"=>nil,
               "volume"=>"0.5",
               "forecastVaccineType"=>"N"},
             "allowableVaccine"=>
              {"vaccineType"=>"OPV",
               "cvx"=>"02",
               "beginAge"=>"6 weeks - 4 days",
               "endAge"=>nil},
             "conditionalSkip"=>nil,
             "recurringDose"=>"No",
             "seasonalRecommendation"=>nil,
             "requiredGender"=>nil
            }
          ]
        }
      ]
    }
  }
  public_constant(:SAMPLEDIPHTHERIA)
  public_constant(:SAMPLEPOLIO)
end