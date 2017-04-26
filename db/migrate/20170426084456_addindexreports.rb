class Addindexreports < ActiveRecord::Migration[5.0]
  def change
    add_index :reports, [:issue_id, :user_id], :unique => true
  end
end
