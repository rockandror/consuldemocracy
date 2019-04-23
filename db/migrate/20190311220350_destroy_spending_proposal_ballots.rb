class DestroySpendingProposalBallots < ActiveRecord::Migration
  def change
    drop_table :ballot_lines
    drop_table :ballots
  end
end
