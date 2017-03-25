# Migration file of the users table creation free comment please give me coins
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.timestamps
    end
  end
end
