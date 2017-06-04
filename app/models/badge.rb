class Badge < ApplicationRecord
  belongs_to :badgeable, polymorphic: true
  validates :title, presence: true
end
