class Exchange < ApplicationRecord
  belongs_to :award
  belongs_to :user
  validates_uniqueness_of :award_id, scope: :user_id
  validates :exchange_auth_token, presence: true
end
