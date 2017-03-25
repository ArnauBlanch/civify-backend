class Issue < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :category, presence: true
  validates :picture, presence: true
  validates :description, presence: true
  validates :risk, presence: true
  validates :solved, presence: true
  validates :supports, presence: true
  validates :reports, presence: true
end
