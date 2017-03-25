# stub class for Issue-User relation
class User < ApplicationRecord
  has_many :issues
end
