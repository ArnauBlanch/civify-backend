# Issue model with validations
class Issue < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :resolutions, join_table: 'resolutions',
                          class_name: 'User'
  has_many :confirmations, dependent: :destroy
  has_many :users_confirming, through: :confirmations, source: :user
  has_many :reports, dependent: :destroy
  has_many :users_reporting, through: :reports, source: :user
  has_secure_token :issue_auth_token
  has_attached_file :picture, preserve_files: 'false',
                    styles: { small: '128x128', med: '256x256' }
  # User large_url for original image size
  validates_attachment_content_type :picture,
                                    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  validates_attachment :picture, size: { in: 0..5.megabytes }
  validates :picture, attachment_presence: true
  validates :user_id, presence: true
  validates :title, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :category, presence: true
  validates :picture, presence: true
  validates :description, presence: true
  validates_inclusion_of :risk, in: [true, false]

  attr_accessor :current_user

  def as_json(options = nil)
    json = super(options.reverse_merge(except: [:id, :user_id, :picture_file_name,
                                                :picture_content_type,
                                                :picture_file_size,
                                                :picture_updated_at]))
           .merge(user_auth_token: user.user_auth_token)
           .merge(confirm_votes: confirm_votes)
           .merge(num_reports: num_reports)
           .merge(picture_hash)

    if @current_user
      json.merge(confirmed_by_auth_user: confirmed_by_auth_user)
          .merge(resolved_by_auth_user: resolved_by_auth_user)
          .merge(reported_by_auth_user: reported_by_auth_user)
    else
      json
    end
  end

  def picture_hash
    { picture: { file_name: picture_file_name,
                 content_type: picture_content_type,
                 file_size: picture_file_size,
                 updated_at: picture_updated_at,
                 small_url: picture.url(:small),
                 med_url: picture.url(:med),
                 large_url: picture.url(:original) } }
  end

  private

  def confirm_votes
    users_confirming.size
  end

  def num_reports
    users_reporting.size
  end

  def reported_by_auth_user
    users_reporting.exists? @current_user.id
  end

  def confirmed_by_auth_user
    users_confirming.exists? @current_user.id
  end

  def resolved_by_auth_user
    resolutions.exists?(@current_user.id)
  end
end
