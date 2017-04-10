# Creates a resolutions table with the user and issue ids
class CreateResolutions < ActiveRecord::Migration[5.0]
  def change
    create_table :resolutions do |t|
      t.integer :user_id
      t.integer :issue_id
    end
  end
end
