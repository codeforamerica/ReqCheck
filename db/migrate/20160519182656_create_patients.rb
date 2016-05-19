class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.integer   :patient_no, null: false
      t.date      :dob, null: false
      t.string    :first_name, null: false
      t.string    :last_name, null: false
      t.string    :address
      t.string    :address2
      t.string    :city
      t.string    :state
      t.string    :zip_code
      t.string    :cell_phone
      t.string    :home_phone
      t.string    :race
      t.string    :ethnicity

      t.timestamps null: false
    end
    add_index :patients, :patient_no
    add_index :patients, :last_name
  end
end
