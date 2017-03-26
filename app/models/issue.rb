# Issue model with validations and foreign key in schema with user
class Issue < ApplicationRecord
  belongs_to :user
  has_secure_token :issue_auth_token
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
end
