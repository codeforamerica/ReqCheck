require 'rails_helper'

RSpec.describe ConditionalSkipSet, type: :model do
  describe "validations" do
    it { should validate_presence_of(:set_id) }
    it { should validate_presence_of(:set_description) }
  end
  describe 'relationships' do
    it 'has many conditions' do
      conditional_skip_set = FactoryGirl.create(:conditional_skip_set)
      conditional_skip_set_condition = FactoryGirl.create(:conditional_skip_set_conditions)
      conditional_skip_set.conditions << conditional_skip_set_condition
      expect(conditional_skip_set.conditions).to eq([conditional_skip_set_condition])
    end
    it 'belongs to a conditional_skip' do
      conditional_skip_set = FactoryGirl.create(:conditional_skip_set)
      conditional_skip     = FactoryGirl.create(:conditional_skip, sets: [conditional_skip_set])
      conditional_skip.sets = [conditional_skip_set]
    end
  end
end
