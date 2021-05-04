class AddColumnCodeDistrict < ActiveRecord::Migration[5.0]
  def up
    add_column :geozones, :code_district, :string
  end

  def down
    remove_column :geozones, :code_district, :string
  end
end
