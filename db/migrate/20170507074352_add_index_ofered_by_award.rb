class AddIndexOferedByAward < ActiveRecord::Migration[5.0]
  def change
    add_index :awards, :ofered_by
  end
end
