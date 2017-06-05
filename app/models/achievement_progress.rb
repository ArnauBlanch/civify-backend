class AchievementProgress < ApplicationRecord
  before_save :complete_give_badge if :proggress_changed?
  belongs_to :user
  belongs_to :achievement
  validates_uniqueness_of :user_id, scope: :achievement_id

  scope :unclaimed, (-> { where(completed: true, claimed: false) })

  def as_json(options = nil)
    achievement.as_json(options)
  end

  private

  def complete_give_badge
    self.completed = progress == achievement.number
    if self.completed
      badge = achievement.badge
      user.badges << badge unless user.badges.exists?(badge.id)
    end

  end
end
