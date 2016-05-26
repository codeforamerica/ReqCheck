class CreateUsers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :users, id: :uuid do |t|
      t.string    :first_name, null: false
      t.string    :last_name, null: false
      t.string    :type

      t.timestamps null: false
    end
  end
end
