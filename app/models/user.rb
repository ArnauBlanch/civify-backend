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
  has_many :achievement_progresses, dependent: :destroy
  has_many :achievements_in_progress, through: :achievement_progresses, source: :achievement
  has_many :event_progresses, dependent: :destroy
  has_many :events_in_progress, through: :event_progresses, source: :event
  has_and_belongs_to_many :badges
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
  enum profile_icon: [:admin_icon, :business_icon, :user_icon, :boy, :boy1,
                      :girl, :girl1, :man, :man1, :man2, :man3, :man4]

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
    super(options.reverse_merge(except: [:id, :password_digest, :xp, :reset_digest, :reset_sent_at]))
      .merge(lv: level)
      .merge(xp: current_xp)
      .merge(xp_max: max_xp)
      .merge(num_badges: badges.size)
  end

  # PASSWORD RESET
  attr_accessor :reset_token

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute :reset_digest, User.digest(reset_token)
    update_attribute :reset_sent_at, Time.zone.now
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Increase achievement progresses by kind
  def increase_achievements_progress(kind)
    achievement_progresses.where(completed: false, claimed: false).each do |ap|
      ap.increase_progress if ap.achievement.kind == kind
    end
  end

   # Increase achievement progresses by kind
  def increase_events_progress(kind)
    event_progresses.where(completed: false, claimed: false).each do |ep|
      ep.increase_progress if ep.event.kind == kind
    end
  end

  def increase_coins_spent_progress(coins)
    achievement_progresses.where(completed: false, claimed: false).each do |ap|
      ap.increase_progress_by coins if ap.achievement.kind == 'coins_spent'
    end
  end

  def can_create_issue
    issues_created_24_hours < (1.5 * level).ceil
  end

  private

  def issues_created_24_hours
    issues.where('created_at >= ?', Time.now - 24.hours).size
  end
end
