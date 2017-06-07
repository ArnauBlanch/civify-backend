class UsersBadgesAsso < ActiveRecord::Migration[5.0]
  def change
    create_table :badges_users, id: false do |t|
      t.belongs_to :badge, index: true
      t.belongs_to :user, index: true
    end
  end
end
