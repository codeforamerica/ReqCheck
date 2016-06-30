class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.integer :antigen_id
      t.string :name, null: false
      t.boolean :default_series, default: false

      t.timestamps null: false
    end
  end
  add_foreign_key :series, :antigens, index: true
end



# <series>
#   <seriesName>Hep A Standard 2-dose series</seriesName>
#   <targetDisease>Hep A</targetDisease>
#   <vaccineGroup>Hep A</vaccineGroup>
#   <selectBest>
#       <defaultSeries>Yes</defaultSeries>
#       <productPath>No</productPath>
#       <seriesPreference>1</seriesPreference>
#       <minAgeToStart>n/a</minAgeToStart>
#       <maxAgeToStart>n/a</maxAgeToStart>
#   </selectBest>
#   <seriesDose>
#       <doseNumber>Dose 1</doseNumber>
#       <age>
#           <absMinAge>12 months - 4 days</absMinAge>
#           <minAge>12 months</minAge>
#           <earliestRecAge>12 months</earliestRecAge>
#           <latestRecAge>24 months + 4 weeks</latestRecAge>
#           <maxAge />
#       </age>
#       <interval />
#       <allowableInterval />
#       <preferableVaccine>
#           <vaccineType>Hep A, adult</vaccineType>
#           <cvx>52</cvx>
#           <beginAge>19 years</beginAge>
#           <endAge />
#           <tradeName />
#           <mvx />
#           <volume>1</volume>
#           <forecastVaccineType>N</forecastVaccineType>
#       </preferableVaccine>
#       <preferableVaccine>
#           <vaccineType>Hep A, ped/adol, 2 dose</vaccineType>
#           <cvx>83</cvx>
#           <beginAge>12 months</beginAge>
#           <endAge>19 years</endAge>
#           <tradeName />
#           <mvx />
#           <volume>0.5</volume>
#           <forecastVaccineType>N</forecastVaccineType>
#       </preferableVaccine>
#       <allowableVaccine>
#           <vaccineType>Hep A, adult</vaccineType>
#           <cvx>52</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge />
#       </allowableVaccine>
#       <allowableVaccine>
#           <vaccineType>Hep A, ped/adol, 2 dose</vaccineType>
#           <cvx>83</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge />
#       </allowableVaccine>
#       <allowableVaccine>
#           <vaccineType>Hep A, Unspecified</vaccineType>
#           <cvx>85</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge />
#       </allowableVaccine>
#       <allowableVaccine>
#           <vaccineType>HepA-HepB</vaccineType>
#           <cvx>104</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge>18 years</endAge>
#       </allowableVaccine>
#       <conditionalSkip />
#       <recurringDose>No</recurringDose>
#       <seasonalRecommendation />
#       <requiredGender />
#   </seriesDose>
#   <seriesDose>
#       <doseNumber>Dose 2</doseNumber>
#       <age>
#           <absMinAge>18 months - 4 days</absMinAge>
#           <minAge>18 months</minAge>
#           <earliestRecAge>18 months</earliestRecAge>
#           <latestRecAge>24 months + 4 weeks</latestRecAge>
#           <maxAge />
#       </age>
#       <interval>
#           <fromPrevious>Y</fromPrevious>
#           <fromTargetDose />
#           <fromMostRecent />
#           <absMinInt>6 months - 4 days</absMinInt>
#           <minInt>6 months</minInt>
#           <earliestRecInt>6 months</earliestRecInt>
#           <latestRecInt>19 months + 4 weeks</latestRecInt>
#           <intervalPriority />
#       </interval>
#       <allowableInterval>
#           <fromPrevious>N</fromPrevious>
#           <fromTargetDose>1</fromTargetDose>
#           <absMinInt>6 months</absMinInt>
#       </allowableInterval>
#       <preferableVaccine>
#           <vaccineType>Hep A, adult</vaccineType>
#           <cvx>52</cvx>
#           <beginAge>19 years</beginAge>
#           <endAge />
#           <tradeName />
#           <mvx />
#           <volume>1</volume>
#           <forecastVaccineType>N</forecastVaccineType>
#       </preferableVaccine>
#       <preferableVaccine>
#           <vaccineType>Hep A, ped/adol, 2 dose</vaccineType>
#           <cvx>83</cvx>
#           <beginAge>12 months</beginAge>
#           <endAge>19 years</endAge>
#           <tradeName />
#           <mvx />
#           <volume>0.5</volume>
#           <forecastVaccineType>N</forecastVaccineType>
#       </preferableVaccine>
#       <allowableVaccine>
#           <vaccineType>Hep A, adult</vaccineType>
#           <cvx>52</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge />
#       </allowableVaccine>
#       <allowableVaccine>
#           <vaccineType>Hep A, ped/adol, 2 dose</vaccineType>
#           <cvx>83</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge />
#       </allowableVaccine>
#       <allowableVaccine>
#           <vaccineType>Hep A, Unspecified</vaccineType>
#           <cvx>85</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge />
#       </allowableVaccine>
#       <allowableVaccine>
#           <vaccineType>HepA-HepB</vaccineType>
#           <cvx>104</cvx>
#           <beginAge>12 months - 4 days</beginAge>
#           <endAge>18 years</endAge>
#       </allowableVaccine>
#       <conditionalSkip />
#       <recurringDose>No</recurringDose>
#       <seasonalRecommendation />
#       <requiredGender />
#   </seriesDose>
# </series>