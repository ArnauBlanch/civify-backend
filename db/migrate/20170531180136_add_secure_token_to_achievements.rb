class AddSecureTokenToAchievements < ActiveRecord::Migration[5.0]
  def change
    add_column :achievements, :achievement_token, :string
    add_index :achievements, :achievement_token, unique: true
  end
end
