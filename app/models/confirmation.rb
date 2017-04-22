# Confirmation model class with user associations
class Confirmation < ApplicationRecord
  belongs_to :issue
  belongs_to :user
  validates_uniqueness_of :user_id, scope: :issue_id
end
