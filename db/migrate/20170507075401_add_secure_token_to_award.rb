class AddSecureTokenToAward < ActiveRecord::Migration[5.0]
  def change
    add_column :awards, :award_auth_token, :string
    add_index :awards, :award_auth_token, unique: true
  end
end
