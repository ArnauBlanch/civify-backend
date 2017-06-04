class AddPaperclipToBadge < ActiveRecord::Migration[5.0]
  def change
    add_attachment :badges, :icon
  end
end
