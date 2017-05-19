class AddFkUsersAwards < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :awards, :users, column: :offered_by
  end
end
