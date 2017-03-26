# stub class for Issue-User relation
class User < ApplicationRecord
  has_many :issues
  has_secure_token :user_auth_token
  validates :name, presence: true
end
