class CreateJoinTableAntigenSeriesDoseAntigenSeriesDoseVaccine < ActiveRecord::Migration
  def change
    create_join_table :antigen_series_doses, :antigen_series_dose_vaccines, table_name: :antigen_series_doses_to_vaccines do |t|
      t.index [:antigen_series_dose_id, :antigen_series_dose_vaccine_id],
        name: 'index_series_doses_to_vaccines_on_series_dose_id',
        unique: true
      t.index [:antigen_series_dose_vaccine_id, :antigen_series_dose_id],
        name: 'index_vaccines_to_series_doses_on_vaccine_id',
        unique: true
    end
  end
end
