class AddEventProgressInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :event_progresses, :completed, :boolean, default: false
    add_column :event_progresses, :claimed, :boolean, default: false
    add_column :event_progresses, :progress, :integer
  end
end
