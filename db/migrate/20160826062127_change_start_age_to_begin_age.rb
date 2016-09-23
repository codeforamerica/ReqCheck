class ChangeStartAgeToBeginAge < ActiveRecord::Migration
  def change
    rename_column(:conditional_skip_set_conditions,
                  :start_age, :begin_age)
  end
end
