class ResolvedVotesDefaultValueZero < ActiveRecord::Migration[5.0]
  def change
    change_column :issues, :resolved_votes, :integer, default: 0
  end
end
