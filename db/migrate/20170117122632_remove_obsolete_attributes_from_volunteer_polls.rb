class RemoveObsoleteAttributesFromVolunteerPolls < ActiveRecord::Migration[4.2]
  def change
    remove_column :volunteer_polls, :availability_week
    remove_column :volunteer_polls, :availability_weekend
  end
end
