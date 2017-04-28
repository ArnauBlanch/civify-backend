class RemoveResolvedAndReportsColumnsFromIssue < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :resolved_votes
    remove_column :issues, :reports
  end
end
