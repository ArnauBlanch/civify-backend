class EventProgress < ApplicationRecord
  belongs_to :user
  belongs_to :event
  validates_uniqueness_of :user_id, scope: :event_id

  scope :unclaimed, (-> { where(completed: true, claimed: false) })
  scope :in_progress, (-> { where(completed: false) })

  def as_json(options = nil)
    event.as_json(options)
  end

  def increase_progress(increment = 1)
    now = Time.now
    return if event.start_date > now || event.end_date < now
    new_progress = progress + increment
    update(progress: new_progress)
    update(completed: true, progress: event.number) if new_progress >= event.number
  end
end
