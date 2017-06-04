class CreateEventProgresses < ActiveRecord::Migration[5.0]
  def change
    create_table :event_progresses do |t|
      t.belongs_to :user, index: false
      t.belongs_to :event, index: false
      t.timestamps
    end
  end
end
