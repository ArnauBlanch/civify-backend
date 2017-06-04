class ProgressDefaultZero < ActiveRecord::Migration[5.0]
  def change
    change_column :event_progresses, :progress, :integer, default: 0
  end
end
