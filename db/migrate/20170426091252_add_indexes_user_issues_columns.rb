class AddIndexesUserIssuesColumns < ActiveRecord::Migration[5.0]
  def change
    add_index :confirmations, :issue_id
    add_index :confirmations, :user_id
    add_index :reports, :issue_id
    add_index :reports, :user_id
  end
end
