class AddProfileIconToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :profile_icon, :integer, default: 2
  end
end
