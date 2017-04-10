# ActiveRecord that represents users in the database
class User < ApplicationRecord
  has_many :issues
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  has_secure_password # method to implement the secure password
  validates :password, presence: true
  validates :password_confirmation, presence: true
  has_secure_token :user_auth_token
  has_and_belongs_to_many :resolutions, join_table: 'resolutions',
                          class_name: 'Issue'
end
