class Validation < ApplicationRecord
  belongs_to :award
  belongs_to :user
  validates_uniqueness_of :award_id, scope: :user_id
end
