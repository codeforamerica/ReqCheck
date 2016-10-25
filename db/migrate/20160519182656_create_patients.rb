class CreatePatients < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :patients, id: :uuid do |t|
      t.string    :first_name, null: false
      t.string    :last_name, null: false
      t.integer   :patient_number, null: false
      t.date      :dob, null: false
      t.string    :email
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
    add_index :patients, :patient_number, unique: true
  end
end
