class AddInterestsCountToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :interests_count, :integer, default: 0
  end
end
