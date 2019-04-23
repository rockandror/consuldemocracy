class AddPhysicalToPollBooths < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_booths, :physical, :boolean, default: true
  end
end
