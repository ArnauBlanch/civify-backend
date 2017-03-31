class TokenFix < ActiveRecord::Migration[5.0]
  def change
    remove_index :issues, :auth_token
    rename_column :issues, :auth_token, :issue_auth_token
    add_index :issues, :issue_auth_token, unique: true
  end
end
