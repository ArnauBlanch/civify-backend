class RemoveConfirmedFromIssue < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :confirmed_by_auth_user
    remove_column :issues, :confirm_votes
  end
end
