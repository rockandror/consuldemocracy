class AddColumnProfilesUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :profiles, :integer
  end
end
