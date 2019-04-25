class DestroySpendingProposalBallots < ActiveRecord::Migration[4.2]
  def change
    drop_table :ballot_lines
    drop_table :ballots
  end
end
