class AchievementProgress < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
end
