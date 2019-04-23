class AddLetterOfficerToPollOfficers < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_officers, :letter_officer, :boolean, default: false
  end
end
