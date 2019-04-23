class AddRepresentativeIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :representative_id, :integer
  end
end
