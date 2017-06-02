class Achievement < ApplicationRecord
  has_secure_token :achievement_token
  enum kind: [:issue, :confirm, :resolve, :reward, :use, :confirm_received,
              :resolve_received, :coins_spent, :issue_resolved, :level]

  # Users
  has_many :achievement_progresses
  has_many :users, through: :achievement_progresses

  validates :title, presence: true
  validates :description, presence: true
  validates :number, presence: true
  validates :kind, presence: true
  validates :coins, presence: true
  validates :xp, presence: true
  validates_uniqueness_of :number, scope: :kind

  def as_json(options = {})
    super(options.reverse_merge(except: [:id, :updated_at]))
  end
end
