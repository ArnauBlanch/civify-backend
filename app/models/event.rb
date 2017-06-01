class Event < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates_uniqueness_of :number, scope: :kind
  validates :start_date, presence: true, date: true
  validates :end_date, presence: true, date: { after_or_equal_to:  :start_date}
  validates :number, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :coins, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :xp, presence: true, numericality: { greater_than_or_equal_to: 0 }
  has_attached_file :image, preserve_files: 'false',
                    styles: { small: '450x450', med: '800x800' }
  # Use large_url for original image size
  validates_attachment_content_type :image,
                                    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  validates_attachment :image, size: { in: 0..5.megabytes }
  has_secure_token :event_token
  enum kind: [:issue, :confirm, :resolve]
  validates :kind, presence: true, inclusion: {in: kinds.keys}

end