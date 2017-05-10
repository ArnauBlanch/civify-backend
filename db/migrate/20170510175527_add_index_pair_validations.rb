class AddIndexPairValidations < ActiveRecord::Migration[5.0]
  def change
    add_index :validations, [:award_id, :user_id], :unique => true
  end
end
