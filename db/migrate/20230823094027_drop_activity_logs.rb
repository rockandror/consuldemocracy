class DropActivityLogs < ActiveRecord::Migration[6.0]
  def change
    drop_table :activity_logs
  end
end
