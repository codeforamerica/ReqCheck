class CreateJoinTableAntigenVaccine < ActiveRecord::Migration
  def change
    create_table :antigens_vaccines, id: false do |t|
      t.belongs_to :antigen, index: true
      t.belongs_to :vaccine, index: true
    end
    add_index :vaccines, :cvx_code
  end
end
