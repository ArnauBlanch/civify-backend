class Badge < ApplicationRecord
  include Xattachable
  before_save :fetch_icon
  before_create :set_title
  belongs_to :badgeable, polymorphic: true
  validates :title, presence: true
  has_attached_file :icon, styles: { thumb: '200x200' }
  validates_attachment_content_type :icon, content_type:
      ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  validates_attachment :icon, size: { in: 0..5.megabytes }
  validates :icon, attachment_presence: true

  private

  def fetch_icon
    fetch_picture
    icon = @picture if @picture
  end

  def set_title
    title = badgeable.title
  end
end
