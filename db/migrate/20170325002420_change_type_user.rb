# Migration file of User name column type change
class ChangeTypeUser < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :name, :string
  end
end
