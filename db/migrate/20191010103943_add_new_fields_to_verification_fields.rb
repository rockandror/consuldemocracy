class AddNewFieldsToVerificationFields < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_fields, :visible, :boolean
    add_column :verification_fields, :represent_geozone, :boolean
    add_column :verification_fields, :represent_min_age_to_participate, :boolean
  end
end
