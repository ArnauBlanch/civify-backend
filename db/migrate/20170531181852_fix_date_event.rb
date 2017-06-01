class FixDateEvent < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :start_date
    remove_column :events, :end_date
    add_column :events, :start_date, :datetime
    add_column :events, :end_date, :datetime
  end
end
