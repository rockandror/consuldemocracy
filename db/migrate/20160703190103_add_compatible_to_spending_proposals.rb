class AddCompatibleToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :compatible, :boolean, default: true
  end
end
