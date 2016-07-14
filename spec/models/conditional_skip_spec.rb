require 'rails_helper'

RSpec.describe ConditionalSkip, type: :model do
  describe "validations" do
  end
  describe 'relationships' do
    it 'has one antigen_series' do
      conditional_skip = FactoryGirl.create(:conditional_skip)
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series.update(conditional_skip: conditional_skip)
      expect(conditional_skip.antigen_series).to eq(antigen_series)
    end
    it 'has many sets' do
      conditional_skip = FactoryGirl.create(:conditional_skip)
      conditional_skip_set = FactoryGirl.create(:conditional_skip_set)
      conditional_skip.sets << conditional_skip_set
      expect(conditional_skip.sets).to eq(conditional_skip_set)
    end
  end
end
