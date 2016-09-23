class ChangeColumnNameOnAntigen < ActiveRecord::Migration
  def change
    rename_column :antigens, :name, :target_disease
  end
end
