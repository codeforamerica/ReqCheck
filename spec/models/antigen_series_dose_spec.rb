require 'rails_helper'

RSpec.describe AntigenSeriesDose, type: :model do
  describe "validations" do
    it { should validate_presence_of(:dose_number) }
  end
  describe 'relationships' do
    it 'has many dose_vaccines' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine)
      antigen_series_dose.dose_vaccines << asd_vaccine
      expect(antigen_series_dose.dose_vaccines).to include(asd_vaccine)
    end
    it 'ensures no duplicates in the join table' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine,
        antigen_series_doses: [antigen_series_dose]
      )
      expect { antigen_series_dose.dose_vaccines << asd_vaccine }
        .to raise_exception(ActiveRecord::RecordNotUnique)
    end
    it 'has many preferable_vaccines' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      FactoryGirl.create(:antigen_series_dose_vaccine, preferable: false)
      FactoryGirl.create(:antigen_series_dose_vaccine, preferable: false)
      FactoryGirl.create(:antigen_series_dose_vaccine, preferable: true)
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine,
        preferable: true
      )
      antigen_series_dose.dose_vaccines << asd_vaccine
      expect(antigen_series_dose.preferable_vaccines).to include(asd_vaccine)
      expect(antigen_series_dose.preferable_vaccines).to eq([asd_vaccine])
      expect(antigen_series_dose.allowable_vaccines).not_to include(asd_vaccine)
    end
    it 'has many allowable_vaccines' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      FactoryGirl.create(:antigen_series_dose_vaccine, preferable: false)
      FactoryGirl.create(:antigen_series_dose_vaccine, preferable: true)
      FactoryGirl.create(:antigen_series_dose_vaccine, preferable: true)
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine,
        preferable: false
      )
      antigen_series_dose.dose_vaccines << asd_vaccine
      expect(antigen_series_dose.allowable_vaccines).to include(asd_vaccine)
      expect(antigen_series_dose.allowable_vaccines).to eq([asd_vaccine])
      expect(antigen_series_dose.preferable_vaccines).not_to include(asd_vaccine)
    end
    it 'can have one conditional_skip' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      conditional_skip = FactoryGirl.create(:conditional_skip)
      antigen_series_dose.update(conditional_skip: conditional_skip)
      expect(antigen_series_dose.conditional_skip).to eq(conditional_skip)
    end
    it 'has one antigen_series' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series.doses << antigen_series_dose
      expect(antigen_series_dose.antigen_series).to eq(antigen_series)
    end
    it 'has many intervals' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      interval_1 = FactoryGirl.create(:interval)
      interval_2 = FactoryGirl.create(:interval)
      antigen_series_dose.intervals << interval_1
      antigen_series_dose.intervals << interval_2
      expect(antigen_series_dose.intervals).to eq([interval_1, interval_2])
      expect(interval_1.antigen_series_dose).to eq(antigen_series_dose)
      expect(interval_2.antigen_series_dose).to eq(antigen_series_dose)
    end
    it 'has many preferable_intervals' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      preferable_interval = FactoryGirl.create(:interval,
        antigen_series_dose: antigen_series_dose, allowable: false
      )
      FactoryGirl.create(:interval, antigen_series_dose: antigen_series_dose, allowable: false)
      FactoryGirl.create(:interval, allowable: false)
      FactoryGirl.create(:interval, allowable: true)
      FactoryGirl.create(:interval, allowable: true)
      expect(antigen_series_dose.preferable_intervals.length).to eq(2)
      expect(antigen_series_dose.preferable_intervals).to include(preferable_interval)
    end
    it 'has many allowable_intervals' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      allowable_interval = FactoryGirl.create(:interval,
        antigen_series_dose: antigen_series_dose, allowable: true
      )
      FactoryGirl.create(:interval, antigen_series_dose: antigen_series_dose, allowable: true)
      FactoryGirl.create(:interval, allowable: false)
      FactoryGirl.create(:interval, allowable: false)
      FactoryGirl.create(:interval, allowable: true)
      expect(antigen_series_dose.allowable_intervals.length).to eq(2)
      expect(antigen_series_dose.allowable_intervals).to include(allowable_interval)
    end
  end
end
