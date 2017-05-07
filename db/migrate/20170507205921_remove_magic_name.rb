class RemoveMagicName < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :name if User.column_names.include?('name')
  end
end
