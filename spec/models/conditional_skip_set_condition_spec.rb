require 'rails_helper'

RSpec.describe ConditionalSkipSetCondition, type: :model do
  describe "validations" do
      it { should validate_presence_of(:condition_id) }
      it { should validate_presence_of(:condition_type) }
  end
  describe 'relationships' do
    it 'belongs to skip_set' do
      condition = FactoryGirl.create(:conditional_skip_condition)
      cs_set = FactoryGirl.create(:conditional_skip_set, conditions: [condition])
      expect(condition.skip_set).to eq(cs_set)
    end
  end
end
