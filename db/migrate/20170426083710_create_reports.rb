class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.belongs_to :user, index: false
      t.belongs_to :issue, index: false
      t.timestamps
    end
  end
end
