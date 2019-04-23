class AddIndexToRedeemableCode < ActiveRecord::Migration[4.2]
  def change
    add_index :redeemable_codes, :token
    add_index :redeemable_codes, :geozone_id
  end
end
