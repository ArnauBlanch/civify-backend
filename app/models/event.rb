class Event < ApplicationRecord
  has_secure_token :event_token
  enum kind: [:issue, :confirm, :resolve, :reward, :use, :confirm_received,
              :resolve_received, :coins_spent, :issue_resolved, :level]

  has_one :badge, as: :badgeable, dependent: :destroy
  has_many :event_progresses, dependent: :destroy
  has_many :users, through: :event_progresses, source: :user

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

  validates :start_date, presence: true, date: true
  validates :end_date, presence: true, date: { after_or_equal_to: :start_date }

  has_attached_file :image, preserve_files: 'false', styles: { small: '450x450', med: '800x800' }
  # Use large_url for original image size
  validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  validates_attachment :image, size: { in: 0..5.megabytes }

  scope :enabled, (->(enabled) { where(enabled: enabled) if enabled.present? })

  cattr_accessor :current_user

  def as_json(options = nil)
    json = super(options.reverse_merge(except: [:id, :user_id, :image_file_name,
                                                :image_content_type,
                                                :image_file_size,
                                                :image_updated_at]))
    json.merge!(picture_hash)
    merge_user_event_progress!(json)
    merge_badge(json)
    json
  end

  private

  def merge_user_event_progress!(json)
    return json unless current_user && enabled && active_event
    ep = event_progresses.find_by_user_id current_user.id
    json.merge!(progress: ep.progress, completed: ep.completed, claimed: ep.claimed) if ep
    json
  end

  def merge_badge(json)
    badge_hash = JSON.parse badge.to_json
    json.merge!(badge: badge_hash )
  end

  def active_event
    return false unless start_date && end_date
    start_date <= Date.today && Date.today <= end_date
  end

  def picture_hash
    { picture: { file_name: image_file_name,
                 content_type: image_content_type,
                 file_size: image_file_size,
                 updated_at: image_updated_at,
                 small_url: image.url(:small),
                 med_url: image.url(:med),
                 large_url: image.url(:original) } }
  end

end