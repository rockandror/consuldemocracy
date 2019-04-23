class AddOfficingVoterToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :officing_voter, :boolean, default: false
  end
end
