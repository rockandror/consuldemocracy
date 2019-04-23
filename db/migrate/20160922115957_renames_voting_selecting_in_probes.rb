class RenamesVotingSelectingInProbes < ActiveRecord::Migration[4.2]
  def change
    rename_column :probes, :voting_allowed, :selecting_allowed
  end
end
