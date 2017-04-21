class AddColumnResolvedVotesFix < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :resolved_votes, :integer
  end
end
