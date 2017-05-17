class IssueTexts < ActiveRecord::Migration[5.0]
  def change
    change_column :issues, :title, :text
    change_column :issues, :description, :text
  end
end
