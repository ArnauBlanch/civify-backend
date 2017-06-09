class CreateBadges < ActiveRecord::Migration[5.0]
  def change
    create_table :badges do |t|
      t.string :title
      t.references :badgeable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
