class AddLabelToBudgetInvestments < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :label, :string, default: nil
  end
end
