class AddColumnBudgets < ActiveRecord::Migration[5.0]
  def change
    add_column :budgets, :budget_link, :text
    add_column :budgets, :budget_link_enabled, :boolean, default: false
  end
end
