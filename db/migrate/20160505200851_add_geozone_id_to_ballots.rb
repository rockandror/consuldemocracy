class AddGeozoneIdToBallots < ActiveRecord::Migration[4.2]
  def change
    add_column :ballots, :geozone_id, :integer
  end
end
