class RemoveGeozoneIdFromRedeemableCodes < ActiveRecord::Migration[4.2]
  def change
    remove_column :redeemable_codes, :geozone_id, :integer
  end
end
