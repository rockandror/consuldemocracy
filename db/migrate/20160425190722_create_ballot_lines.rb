class CreateBallotLines < ActiveRecord::Migration[4.2]
  def change
    create_table :ballot_lines do |t|
      t.integer :ballot_id
      t.integer :spending_proposal_id
      t.timestamps null: false
    end
  end
end
