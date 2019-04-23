class AddSpendingIdToBudgetInvesment < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_investments, :original_spending_proposal_id, :integer
  end
end
