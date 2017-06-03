class Achievement < ApplicationRecord
  has_secure_token :achievement_token
  enum kind: [:issue, :confirm, :resolve, :reward, :use, :confirm_received,
              :resolve_received, :coins_spent, :issue_resolved, :level]

  # Users
  has_many :achievement_progresses, dependent: :destroy
  has_many :users, through: :achievement_progresses

  validates :title, presence: true
  validates :description, presence: true
  validates :number, presence: true
  validates :kind, presence: true
  validates :coins, presence: true
  validates :xp, presence: true
  validates_uniqueness_of :number, scope: :kind

  cattr_accessor :current_user

  def as_json(options = {})
    json = super(options.reverse_merge(except: [:id, :updated_at]))

    if current_user && current_user.kind == 'normal'
      json = json.merge(current_user_achievement)
    end

    json
  end

  private

  def current_user_achievement
    ap = achievement_progresses.find_by(user_id: current_user.id)
    {
      progress: ap.progress,
      completed: ap.completed,
      claimed: ap.claimed
    }
  end
end
