class Achievement < ApplicationRecord
  has_secure_token :achievement_token
  enum kind: [:issue, :confirm, :resolve, :reward, :use, :confirm_received,
              :resolve_received, :coins_spent, :issue_resolved, :level]

  validates :title, presence: true
  validates :description, presence: true
  validates :number, presence: true
  validates :kind, presence: true
  validates :coins, presence: true
  validates :xp, presence: true
  validates_uniqueness_of :number, scope: :kind
end
