class FixFial < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :token, :string
    remove_column :users, :token, :string
  end
end
