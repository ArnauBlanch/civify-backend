class CreateAchievements < ActiveRecord::Migration[5.0]
  def change
    create_table :achievements do |t|
      t.string :title
      t.string :description
      t.integer :number
      t.integer :kind
      t.integer :coins
      t.integer :xp

      t.timestamps
    end
  end
end
