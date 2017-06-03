class CreateAchievementProgresses < ActiveRecord::Migration[5.0]
  def change
    create_table :achievement_progresses do |t|
      t.belongs_to :user, index: true
      t.belongs_to :achievement, index: true
      t.integer :progress, default: 0
      t.boolean :completed, default: false
      t.boolean :claimed, default: false

      t.timestamps
    end
  end
end
