class Badge < ApplicationRecord
  belongs_to :badgeable, polymorphic: true
  validates :title, presence: true
  has_attached_file :icon, styles: { thumb: '200x200' }
  validates_attachment_content_type :icon, content_type:
      ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  validates_attachment :icon, size: { in: 0..5.megabytes }
  validates :icon, attachment_presence: true

  def as_json(options = nil)
    super(options.reverse_merge(except: [:id, :icon_file_name, :icon_content_type,
                                         :icon_file_size, :icon_updated_at,
                                         :badgeable_type, :badgeable_id]))
    .merge(icon_hash)

  end

  private

  def icon_hash
    {
     content_type: icon_content_type,
     file_size: icon_file_size,
     updated_at: icon_updated_at,
     icon_url: icon.url(:thumb)
    }
  end
end
