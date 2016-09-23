class RemoveAllowableIntervalFromAntigenSeriesDoses < ActiveRecord::Migration
  def change
    remove_column :antigen_series_doses, :allowable_interval_type
    remove_column :antigen_series_doses, :allowable_interval_absolute_min
  end
end
