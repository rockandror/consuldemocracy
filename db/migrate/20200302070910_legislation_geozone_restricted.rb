class LegislationGeozoneRestricted < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :geozone_restricted, :boolean, default: false, index: true
  end
end
