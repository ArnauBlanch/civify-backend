# ActiveRecord that represents users in the database
class User < ApplicationRecord
  has_many :issues
  has_many :confirmations, dependent: :destroy
  has_many :confirmed_issues, through: :confirmations, source: :issue
  has_many :reports, dependent: :destroy
  has_many :reported_issues, through: :reports, source: :issue
  enum kind: [:normal, :business, :admin]
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  has_secure_password # method to implement the secure password
  validates :password, presence: true
  validates :password_confirmation, presence: true
  has_secure_token :user_auth_token
end
