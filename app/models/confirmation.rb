class Confirmation < ApplicationRecord
  belongs_to :issue
  belongs_to :usser
end
