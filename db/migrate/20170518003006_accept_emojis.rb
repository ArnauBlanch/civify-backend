class AcceptEmojis < ActiveRecord::Migration[5.0]
  def change
    # for each table that will store unicode (like emojis) execute:
    execute "ALTER TABLE issues CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    execute "ALTER TABLE issues CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            MODIFY title TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            MODIFY description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
  end
end
