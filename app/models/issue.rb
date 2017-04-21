# Issue model with validations
class Issue < ApplicationRecord
  belongs_to :user
  has_many :confirmations, dependent: :destroy
  has_many :users_confirming, through: :confirmations, source: :user
  has_secure_token :issue_auth_token
  has_attached_file :picture, styles: { small: '64x64', med: '100x100', large: '200x200' }
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
  validates :risk, presence: true
  validates :resolved_votes, presence: true
  validates :confirm_votes, presence: true
  validates :reports, presence: true

  attr_accessor :current_user

  def as_json(options = nil)
    json = super(options.reverse_merge(except: [:id, :user_id, :picture_file_name,
                                 :picture_content_type,
                                 :picture_file_size,
                                 :picture_updated_at]))
      .merge(user_auth_token: user.user_auth_token)
      .merge(confirm_votes: confirm_votes)
      .merge(picture_hash)
      .merge(confirmed_by_auth_user: confirmed_by_auth_user)
  end

  def picture_hash
    { picture: { file_name: picture_file_name,
                 content_type: picture_content_type,
                 file_size: picture_file_size,
                 updated_at: picture_updated_at,
                 small_url: picture.url(:small),
                 med_url: picture.url(:med),
                 large_url: picture.url(:large) } }
  end

  private

  def confirm_votes
    users_confirming.size
  end

  def confirmed_by_auth_user
    users_confirming.include? @current_user
  end
end
