class AddJsonToAntigen < ActiveRecord::Migration
  def change
    add_column :antigens, :xml_hash, :json
  end
end
