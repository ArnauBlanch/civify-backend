class FixPaperclipToIssue < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :issues, :image
    add_attachment :issues, :picture
  end
end
