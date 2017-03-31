# Migration file of Users column name addition
class AddNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name, :integer
  end
end
