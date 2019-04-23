class AddTotalVotesToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :confidence_score, :integer, default: 0, null: false
  end
end
