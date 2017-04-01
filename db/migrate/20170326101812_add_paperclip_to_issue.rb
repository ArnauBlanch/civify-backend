class AddPaperclipToIssue < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :picture
    add_attachment :issues, :image
  end
end
