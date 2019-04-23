class DropBudgetPolls < ActiveRecord::Migration[4.2]
  def change
    drop_table :budget_polls
  end
end
