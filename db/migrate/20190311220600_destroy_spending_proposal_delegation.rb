class DestroySpendingProposalDelegation < ActiveRecord::Migration
  def change
    remove_column :users, :representative_id
    remove_column :users, :accepted_delegation_alert

    drop_table :forums
    remove_column :votes, :delegated
  end
end
