class EventProgress < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, scope: :event_id

  scope :unclaimed, (-> { where(completed: true, claimed: false) })

  def as_json(options = nil)
    event.as_json(options)
  end

  def increase_progress
    update!(progress + 1)
  end
end
