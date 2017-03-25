class AddNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name, :integer
  end
end
