class AchievementProgress < ApplicationRecord
  after_save :give_badge if :completed_changed?
  belongs_to :user
  belongs_to :achievement
  validates_uniqueness_of :user_id, scope: :achievement_id

  scope :unclaimed, (-> { where(completed: true, claimed: false) })

  def as_json(options = nil)
    achievement.as_json(options)
  end

  private

  def give_badge
    user.badges << achievement.badge if completed
  end
end
