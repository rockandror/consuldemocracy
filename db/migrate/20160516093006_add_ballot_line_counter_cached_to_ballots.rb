class AddBallotLineCounterCachedToBallots < ActiveRecord::Migration[4.2]
  def change
    add_column :ballots, :ballot_lines_count, :integer, default: 0
  end
end
