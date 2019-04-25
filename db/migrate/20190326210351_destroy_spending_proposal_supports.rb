class DestroySpendingProposalSupports < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :district_wide_spending_proposals_supported_count
    remove_column :users, :city_wide_spending_proposals_supported_count
    remove_column :users, :supported_spending_proposals_geozone_id
  end
end
