class AcceptEmojis < ActiveRecord::Migration[5.0]
  def change
    # for each table that will store unicode (like emojis) execute:
    execute "ALTER TABLE issues CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    execute "ALTER TABLE issues CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
            MODIFY title TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
            MODIFY description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
  end
end
