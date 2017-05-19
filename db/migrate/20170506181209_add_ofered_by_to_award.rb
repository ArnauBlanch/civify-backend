class AddOferedByToAward < ActiveRecord::Migration[5.0]
  def change
    add_column :awards, :ofered_by, :integer
  end
end
