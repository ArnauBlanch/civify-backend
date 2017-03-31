class TokenUserFix2 < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :auth_token
    rename_column :users, :auth_token, :user_auth_token
    add_index :users, :user_auth_token, unique: true
  end
end
