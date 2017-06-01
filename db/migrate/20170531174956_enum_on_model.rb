class EnumOnModel < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :kind
    add_column :events, :kind, :integer
  end
end
