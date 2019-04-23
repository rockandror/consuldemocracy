class AddHelpToBudgetPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_polls, :help, :boolean
  end
end
