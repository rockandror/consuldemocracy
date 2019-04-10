class AddDateOfBirthToPollVoters < ActiveRecord::Migration
  def change
    add_column :poll_voters, :date_of_birth, :date
  end
end
