class AddAuthTokenToExchange < ActiveRecord::Migration[5.0]
  def change
    add_column :exchanges, :exchange_auth_token, :string
    add_index :exchanges, :exchange_auth_token, unique: true
  end
end
