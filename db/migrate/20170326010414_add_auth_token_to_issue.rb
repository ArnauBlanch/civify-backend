class AddAuthTokenToIssue < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :auth_token, :string
    add_index :issues, :auth_token, unique: true
  end
end
