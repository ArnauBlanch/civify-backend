# ActiveRecord that represents users in the database
class User < ApplicationRecord
  before_save { self.email = email.downcase } # to ensure uniqueness
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  has_secure_password # method to implement the secure password
  validates :password, presence: true
end
