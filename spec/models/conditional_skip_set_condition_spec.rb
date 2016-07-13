require 'rails_helper'

RSpec.describe ConditionalSkipSetCondition, type: :model do
  describe "validations" do
      it { should validate_presence_of(:condition_id) }
      it { should validate_presence_of(:condition_type) }
  end
  describe 'relationships' do
    it 'has one conditional_skip_set' do
      set_condition = FactoryGirl.create(:conditional_skip_set_condition)
      cs_set = FactoryGirl.create(:conditional_skip_set, conditions: [set_condition])
      expect(cs_set.conditions.first).to eq(set_condition)
    end
  end
end
