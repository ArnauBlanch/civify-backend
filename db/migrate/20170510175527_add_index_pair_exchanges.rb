class AddIndexPairExchanges < ActiveRecord::Migration[5.0]
  def change
    add_index :exchanges, [:award_id, :user_id], :unique => true
  end
end
