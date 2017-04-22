# Creates a resolutions table with the user and issue ids
class CreateResolutions < ActiveRecord::Migration[5.0]
  def change
    create_table :resolutions do |t|
      t.belongs_to :user, index: true
      t.belongs_to :issue, index: true
    end
  end
end
