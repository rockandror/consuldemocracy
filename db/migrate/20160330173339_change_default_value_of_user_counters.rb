class ChangeDefaultValueOfUserCounters < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :district_wide_spending_proposals_supported_count, :integer, default: 10
    change_column :users, :city_wide_spending_proposals_supported_count, :integer, default: 10
  end
end
