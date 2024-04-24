class AddVisitorIdAndStartedAtIndexToVisits < ActiveRecord::Migration[6.1]
  def change
    add_index :visits, [:visitor_id, :started_at]
  end
end
