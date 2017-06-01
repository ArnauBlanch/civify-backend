class AddPaperclipToEvent < ActiveRecord::Migration[5.0]
  def change
    add_attachment :events, :image
  end
end
