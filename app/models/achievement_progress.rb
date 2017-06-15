class AchievementProgress < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  validates_uniqueness_of :user_id, scope: :achievement_id

  scope :unclaimed, (-> { where(completed: true, claimed: false) })
  scope :in_progress, (-> { where(completed: false) })

  def as_json(options = nil)
    achievement.as_json(options)
  end

  def increase_progress(increment = 1)
    new_progress = progress + increment
    update(progress: new_progress)
    update(completed: true, progress: achievement.number) if new_progress >= achievement.number
  end
end
