class AddExperienceToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :xp, :integer, default: 0, limit: 8 # BIGINT 8 bytes
  end
end
