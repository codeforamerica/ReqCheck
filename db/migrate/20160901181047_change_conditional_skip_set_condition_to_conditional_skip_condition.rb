class ChangeConditionalSkipSetConditionToConditionalSkipCondition < ActiveRecord::Migration
  def change
    rename_table(:conditional_skip_set_conditions, :conditional_skip_conditions)
  end
end
