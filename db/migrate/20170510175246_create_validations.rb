class CreateValidations < ActiveRecord::Migration[5.0]
  def change
    create_table :validations do |t|
      t.belongs_to :user, index: true
      t.belongs_to :award, index: true
      t.timestamps
    end
  end
end
