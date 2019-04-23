class AddFieldsToVolunteerPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :volunteer_polls, :first_name, :string
    add_column :volunteer_polls, :last_name, :string
    add_column :volunteer_polls, :document_number, :string
    add_column :volunteer_polls, :phone, :string
  end
end
