require 'csv'

namespace 'cdsi' do
  desc 'load CDSI test cases from spreadsheet & save in DB'
  task load: :environment do
    Rails.logger.level = 1 # hides all the SQL for development

    CSV.foreach('./spec/cdsi-test-cases-subset.csv', headers: true) do |row|
      patient = create_patient row
      
      (1..7).each do |i|
        unless row["Date_Administered_#{i}"].nil?
          create_immunization(patient.patient_profile, row, i)
        end
      end
      puts Patient.where(last_name: 'Tester').count
    end
  end
end

def create_patient(row)
  Patient.create(first_name: "Test #{row['CDC_Test_ID']}",
              last_name: 'Tester',
              patient_profile_attributes: { 
                dob: fix_date(row['DOB']), 
                record_number: $. }
             )
end

def create_immunization(patient_profile, row, series_num)
  Immunization.create(vaccine_code: row["CVX_#{series_num}"],
                   description: row["Vaccine_Name_#{series_num}"],
                   imm_date: fix_date(row["Date_Administered_#{series_num}"]), 
                   patient_profile: patient_profile
                  )
end

def fix_date date_string
  DateTime.strptime(date_string, "%m/%d/%Y").to_date
end

# Headers:
# CDC_Test_ID
# Test_Case_Name
# DOB
# Gender (not in patient_profile)
# Med_History_Text
# Med_History_Code
# Med_History_Code_Sys
# Series_Status
# Date_Administered_1 Vaccine_Name_1  CVX_1 MVX_1 Evaluation_Status_1 Evaluation_Reason_1
# Date_Administered_2 Vaccine_Name_2  CVX_2 MVX_2 Evaluation_Status_2 Evaluation_Reason_2
# Date_Administered_3 Vaccine_Name_3  CVX_3 MVX_3 Evaluation_Status_3 Evaluation_Reason_3 
# Date_Administered_4 Vaccine_Name_4  CVX_4 MVX_4 Evaluation_Status_4 Evaluation_Reason_4 
# Date_Administered_5 Vaccine_Name_5  CVX_5 MVX_5 Evaluation_Status_5 Evaluation_Reason_5 
# Date_Administered_6 Vaccine_Name_6  CVX_6 MVX_6 Evaluation_Status_6 Evaluation_Reason_6 
# Date_Administered_7 Vaccine_Name_7  CVX_7 MVX_7 Evaluation_Status_7 Evaluation_Reason_7 
# Forecast_#
# Earliest_Date Recommended_Date  Past_Due_Date
# Vaccine_Group Assessment_Date
# Evaluation_Test_Type
# Date_added  Date_updated
# Forecast_Test_Type
# Reason_For_Change Changed_In_Version
