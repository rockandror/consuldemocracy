class AddForumToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :forum, :boolean, default: false
  end
end
