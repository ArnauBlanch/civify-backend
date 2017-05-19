class AddUsedToExchange < ActiveRecord::Migration[5.0]
  def change
    add_column :exchanges, :used, :boolean, default: false
  end
end
