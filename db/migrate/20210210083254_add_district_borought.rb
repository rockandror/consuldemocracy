class AddDistrictBorought < ActiveRecord::Migration[5.0]
  def up
    add_column :sures_actuations, :borought, :string
    add_reference :sures_actuations, :geozone, index: true, foreign_key: true
  end

  def down
    remove_column :sures_actuations, :borought
    remove_reference :sures_actuations, :geozone
  end
end
