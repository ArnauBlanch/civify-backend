class AddIndexToEventProgress < ActiveRecord::Migration[5.0]
  def change
    add_index :event_progresses, [:event_id, :user_id], :unique => true
  end
end
