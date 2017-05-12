# ActiveRecord that represents users in the database
class User < ApplicationRecord
  has_many :issues
  has_many :confirmations, dependent: :destroy
  has_many :confirmed_issues, through: :confirmations, source: :issue
  has_many :reports, dependent: :destroy
  has_many :reported_issues, through: :reports, source: :issue
  enum kind: [:normal, :business, :admin]
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :coins, numericality: { greater_than_or_equal_to: 0 }
  validates :xp, numericality: { greater_than_or_equal_to: 0 }
  has_secure_password # method to implement the secure password
  has_secure_token :user_auth_token

  XP_CURVE_CONSTANT = 0.1
  MAX_LEVEL = 100

  def as_json(options = {})
    super(add_level(options.reverse_merge(except: [:id, :password_digest, :updated_at, :xp])))
  end

  def add_level(json)
    level = Math.floor(XP_CURVE_CONSTANT * Math.sqrt(xp)) + 1
    level = MAX_LEVEL if level > MAX_LEVEL
    xp_current = xp - ((level - 1) / XP_CURVE_CONSTANT)**2
    xp_max = (level / XP_CURVE_CONSTANT)**2 - ((level - 1) / XP_CURVE_CONSTANT)**2
    json.merge(lv: level)
        .merge(xp: xp_current)
        .merge(xp_next_level: xp_max)
  end
end
