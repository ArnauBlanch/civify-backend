class AddConfirmedByAuthUserToIssue < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :confirmed_by_auth_user, :boolean, default: false
  end
end
