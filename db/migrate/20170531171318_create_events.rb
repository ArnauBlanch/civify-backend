class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :description
      t.date :start_date
      t.date :end_date
      t.integer :number
      t.integer :coins
      t.integer :xp
      t.column :kind, "ENUM('issue', 'confirm', 'resolve')"
      t.timestamps
    end
  end
end
