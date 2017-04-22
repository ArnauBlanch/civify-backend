class CreateConfirmations < ActiveRecord::Migration[5.0]
  def change
    create_table :confirmations do |t|
      t.belongs_to :issue, index: true
      t.belongs_to :user, index: true
      t.timestamps
    end
  end
end
