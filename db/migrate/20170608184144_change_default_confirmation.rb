class ChangeDefaultConfirmation < ActiveRecord::Migration[5.0]
  def change
    change_column :confirmations, :confirmed, :boolean, default: true
  end
end
