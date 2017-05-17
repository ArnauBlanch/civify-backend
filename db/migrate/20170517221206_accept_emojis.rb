class AcceptEmojis < ActiveRecord::Migration[5.0]
  def change
    # for each table that will store unicode (like emojis) execute:
    execute "ALTER TABLE issues CHARACTER SET utf8mb4"
    execute "ALTER TABLE issues CONVERT TO CHARACTER SET utf8mb4"
  end
end
