class AddEnabledVotingToProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :proposals, :enabled_voting, :boolean
  end
end
