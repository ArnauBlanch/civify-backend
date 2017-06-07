class Badge < ApplicationRecord
  belongs_to :badgeable, polymorphic: true
  has_and_belongs_to_many :users
  validates :title, presence: true
  has_attached_file :icon, styles: { thumb: '200x200' }
  validates_attachment_content_type :icon, content_type:
      ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  validates_attachment :icon, size: { in: 0..5.megabytes }
  validates :icon, attachment_presence: true

  cattr_accessor :current_user

  def as_json(options = nil)
    json = super(options.reverse_merge(except: [:id, :icon_file_name, :icon_content_type,
                                         :icon_file_size, :icon_updated_at,
                                         :badgeable_type, :badgeable_id]))
    json.merge!(icon_hash)
    merge_optained_date(json)
    merge_badgeable_type_token(json)
  end

  private

  def icon_hash
    {
     content_type: icon_content_type,
     file_size: icon_file_size,
     updated_at: icon_updated_at,
     large_url: icon.url(:thumb)
    }
  end

  def merge_optained_date(json)
    return json unless current_user && badgeable_user_progress
    json.merge!(optained_date: @user_progress.updated_at )
  end

  def merge_badgeable_type_token(json)
    type = badgeable_type.downcase
    token_name = type << '_token'
    return json unless badgeable.respond_to? token_name
    json.merge!(corresponds_to_type: badgeable_type, corresponds_to_token: badgeable.public_send(token_name) )
  end

  def badgeable_user_progress
    type = badgeable_type.downcase
    progresses_name = type << '_progresses'
    return false unless badgeable.respond_to? progresses_name
    progresses = badgeable.public_send(progresses_name)
    @user_progress = progresses.find_by_user_id current_user.id
  end
end
