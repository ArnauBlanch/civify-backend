class EventProgress < ApplicationRecord
  after_save :give_badge if :completed_changed?
  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, scope: :event_id

  scope :unclaimed, (-> { where(completed: true, claimed: false) })

  def as_json(options = nil)
    event.as_json(options)
  end

  private

  def give_badge
    user.badges << event.badge if completed
  end
end
