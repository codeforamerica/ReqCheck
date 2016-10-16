class AddHdFieldsToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :hd_mpfile_updated_at, :datetime
    add_column :patients, :family_number, :integer
  end
end
