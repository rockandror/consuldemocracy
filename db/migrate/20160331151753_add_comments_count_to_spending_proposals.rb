class AddCommentsCountToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :comments_count, :integer, default: 0
  end
end
