class RenameAttributesAndSolved < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :solved
    add_column :issues, :resolved_votes, :integer
    rename_column :issues, :name, :title
    rename_column :issues, :supports, :confirm_votes
  end
end
