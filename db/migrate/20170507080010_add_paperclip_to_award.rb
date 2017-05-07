class AddPaperclipToAward < ActiveRecord::Migration[5.0]
  def change
    add_attachment :awards, :picture
  end
end
