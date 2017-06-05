class Achievement < ApplicationRecord
  has_secure_token :achievement_token
  enum kind: [:issue, :confirm, :resolve, :reward, :use, :confirm_received,
              :resolve_received, :coins_spent, :issue_resolved, :level]

  has_one :badge, as: :badgeable, dependent: :destroy
  has_many :achievement_progresses, dependent: :destroy
  has_many :users, through: :achievement_progresses

  validates :title, presence: true
  validates :description, presence: true
  validates :number, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :kind, presence: true
  validates :coins, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :xp, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates_associated :badge
  validates_presence_of :badge
  validates_inclusion_of :enabled, in: [true, false]
  validates_uniqueness_of :number, scope: :kind

  scope :enabled, (->(enabled) { where(enabled: enabled.nil? ? true : enabled) })

  cattr_accessor :current_user

  def as_json(options = {})
    json = super(options.reverse_merge(except: [:id, :user_id]))
    merge_user_achievement_progress!(json)
    merge_badge!(json)
    json
  end

  private

  def merge_user_achievement_progress!(json)
    return json unless current_user && enabled
    ap = achievement_progresses.find_by_user_id current_user.id
    json.merge!(progress: ap.progress, completed: ap.completed, claimed: ap.claimed) if ap
    json
  end

  def merge_badge!(json)
    badge_hash = JSON.parse badge.to_json
    json.merge!(badge: badge_hash)
  end

end
