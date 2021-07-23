class AddEnabledVotingToProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :proposals, :voting_enabled, :boolean
  end
end
