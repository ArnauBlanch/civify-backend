class AddTokenToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :event_token, :string
    add_index :events, :event_token, unique: true
  end
end
