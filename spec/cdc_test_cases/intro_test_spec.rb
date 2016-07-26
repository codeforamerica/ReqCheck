require 'rails_helper'

RSpec.describe 'CDC Tests' do
  before do
    new_time = Time.local(2016, 1, 3, 10, 0, 0)
    Timecop.freeze(new_time)
  end

  after do
    Timecop.return
  end
end