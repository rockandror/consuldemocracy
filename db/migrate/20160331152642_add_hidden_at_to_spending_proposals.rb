class AddHiddenAtToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :hidden_at, :datetime
  end
end
