class CreateResoultions < ActiveRecord::Migration[5.0]
  def change
    create_table :resoultions do |t|
      t.belongs_to :user, index: true
      t.belongs_to :issue, index: true
      t.boolean :marked_resolved, default: true
      t.timestamps
    end
  end
end
