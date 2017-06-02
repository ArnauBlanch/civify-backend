# ActiveRecord that represents users in the database
class User < ApplicationRecord
  has_many :issues
  has_many :offered_awards, dependent: :destroy, foreign_key: 'offered_by', class_name: 'Award'
  has_many :exchanges, dependent: :destroy
  has_many :exchanged_awards, through: :exchanges, source: :award
  has_many :confirmations, dependent: :destroy
  has_many :confirmed_issues, through: :confirmations, source: :issue
  has_many :reports, dependent: :destroy
  has_many :reported_issues, through: :reports, source: :issue

  # Achievements
  has_many :achievement_progresses
  has_many :achievements_in_progress, through: :achievement_progresses,
           source: :achievement

  enum kind: [:normal, :business, :admin]
  validates :kind, presence: true, inclusion: {in: kinds.keys}
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :coins, numericality: { greater_than_or_equal_to: 0 }
  validates :xp, numericality: { greater_than_or_equal_to: 0 }
  has_secure_password # method to implement the secure password
  has_secure_token :user_auth_token

  XP_CURVE_CONSTANT = 0.1
  MIN_LEVEL = 1
  MAX_LEVEL = 100

  def level
    raw_level = (XP_CURVE_CONSTANT * Math.sqrt(xp)).floor
    [[MIN_LEVEL, raw_level].max, MAX_LEVEL].min
  end

  def current_xp
    lv = level
    return 0 if lv == MAX_LEVEL
    xp - User.get_min_xp_from_lv(lv)
  end

  def max_xp
    lv = level
    User.get_min_xp_from_lv(lv + 1) - User.get_min_xp_from_lv(lv)
  end

  def self.get_min_xp_from_lv(lv)
    return 0 if lv <= MIN_LEVEL
    ((lv / XP_CURVE_CONSTANT)**2).ceil
  end

  def as_json(options = {})
    super(options.reverse_merge(except: [:id, :password_digest, :updated_at, :xp]))
      .merge(lv: level)
      .merge(xp: current_xp)
      .merge(xp_max: max_xp)
  end

end
