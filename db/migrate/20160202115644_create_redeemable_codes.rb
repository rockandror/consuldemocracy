class CreateRedeemableCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :redeemable_codes do |t|
      t.string :token
      t.integer :geozone_id

      t.timestamps null: false
    end
  end
end
