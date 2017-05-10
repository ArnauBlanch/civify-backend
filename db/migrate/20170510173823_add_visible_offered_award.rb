class AddVisibleOfferedAward < ActiveRecord::Migration[5.0]
  def change
    add_column :awards, :visible, :boolean, default: true
  end
end
