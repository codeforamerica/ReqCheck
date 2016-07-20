class CreateJoinTableAntigenVaccineInfo < ActiveRecord::Migration
  def change
    create_table :antigens_vaccine_infos, id: false do |t|
      t.belongs_to :antigen, index: true
      t.belongs_to :vaccine_info, index: true
    end
    add_index :vaccine_infos, :cvx_code
  end
end
