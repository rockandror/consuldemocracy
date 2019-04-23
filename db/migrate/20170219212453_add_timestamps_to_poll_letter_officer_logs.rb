class AddTimestampsToPollLetterOfficerLogs < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :poll_letter_officer_logs
  end
end
