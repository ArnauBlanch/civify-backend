class CreateExchanges < ActiveRecord::Migration[5.0]
  def change
    create_table :exchanges do |t|
      t.belongs_to :user, index: true
      t.belongs_to :award, index: true
      t.timestamps
    end
  end
end
