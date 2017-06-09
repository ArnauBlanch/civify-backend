# Had to delete resolutions table to add a new one with timestamps (for model Resolution)
class AddTimestampsToResolutions < ActiveRecord::Migration[5.0]
  def change
    drop_table :resolutions
  end
end
