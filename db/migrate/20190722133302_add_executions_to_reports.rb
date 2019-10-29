class AddExecutionsToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :executions, :boolean, default: true
  end
end
