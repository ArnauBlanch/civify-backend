class Addremoveindexes < ActiveRecord::Migration[5.0]
  def change
    remove_index :confirmations, :issue_id
    remove_index :confirmations, :user_id
    add_index :confirmations, [:issue_id, :user_id], :unique => true
  end
end
