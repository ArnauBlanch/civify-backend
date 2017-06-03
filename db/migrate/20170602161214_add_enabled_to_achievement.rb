class AddEnabledToAchievement < ActiveRecord::Migration[5.0]
  def change
    add_column :achievements, :enabled, :boolean, default: true
  end
end
