class AddMarkedReportedReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :marked_reported, :boolean, default: true
  end
end
