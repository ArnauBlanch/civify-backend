class AddEnabledToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :enabled, :boolean, default: true
  end
end
