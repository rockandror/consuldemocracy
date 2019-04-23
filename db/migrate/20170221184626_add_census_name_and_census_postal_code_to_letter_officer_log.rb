class AddCensusNameAndCensusPostalCodeToLetterOfficerLog < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_letter_officer_logs, :census_name, :string
    add_column :poll_letter_officer_logs, :census_postal_code, :string
  end
end
