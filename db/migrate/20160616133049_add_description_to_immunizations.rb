class AddDescriptionToImmunizations < ActiveRecord::Migration
  def change
    add_column :immunizations, :description, :string
  end
end
