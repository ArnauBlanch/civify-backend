class CreateAchievementProgresses < ActiveRecord::Migration[5.0]
  def change
    create_table :achievement_progresses do |t|
      t.integer :user_id, index: true
      t.integer :achievement_id, index: true
      t.integer :progress, default: 0
      t.boolean :completed, default: false
      t.boolean :claimed, default: false

      t.timestamps
    end
  end
end
