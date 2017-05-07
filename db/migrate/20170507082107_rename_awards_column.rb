class RenameAwardsColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :awards, :ofered_by, :offered_by
  end
end
