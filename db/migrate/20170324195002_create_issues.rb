# Migration file of Issues table creation
class CreateIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :issues do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :category
      t.string :picture
      t.string :description
      t.boolean :risk
      t.boolean :solved
      t.integer :reports
      t.integer :supports
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
