# Award model class
class Award < ApplicationRecord
  belongs_to :commerce_offering, foreign_key: 'offered_by', class_name: 'User'
  has_many :exchanges, dependent: :destroy
  has_many :users_exchanging, through: :exchanges, source: :user
  has_secure_token :award_auth_token
  has_attached_file :picture, preserve_files: 'false', styles: { small: '450x450', med: '800x800' }
  # Use large_url for original image size
  validates_attachment_content_type :picture,
                                    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  validates_attachment :picture, size: { in: 0..5.megabytes }
  validates :picture, attachment_presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true
  validates :commerce_offering, presence: true, null: false

  def as_json(options = nil)
    super(options.reverse_merge(except: [:id, :picture_file_name, :picture_content_type,
                                                :picture_file_size, :picture_updated_at]))
      .merge(offered_by: commerce_offering.first_name)
      .merge(num_exchanges: num_exchanges)
      .merge(num_usages: num_usages)
      .merge(picture_hash)
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

  def num_exchanges
    exchanges.size
  end

  def num_usages
    exchanges.where(used: true).size
  end
end
