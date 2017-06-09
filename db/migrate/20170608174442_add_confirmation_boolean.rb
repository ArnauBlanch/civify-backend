class AddConfirmationBoolean < ActiveRecord::Migration[5.0]
  def change
    add_column :confirmations, :confirmed, :boolean, default: false
  end
end
