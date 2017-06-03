class AchievementProgress < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  validates_uniqueness_of :user_id, scope: :achievement_id
end
