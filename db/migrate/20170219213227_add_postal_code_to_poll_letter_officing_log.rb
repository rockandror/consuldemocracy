class AddPostalCodeToPollLetterOfficingLog < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_letter_officer_logs, :postal_code, :string
  end
end
