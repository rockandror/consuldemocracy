class AddUserIdToLetterOfficerLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_letter_officer_logs, :user_id, :integer
  end
end
