class AddResolvedColumnIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :resolved, :boolean, default: false
  end
end
