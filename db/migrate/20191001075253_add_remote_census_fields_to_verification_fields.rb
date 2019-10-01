class AddRemoteCensusFieldsToVerificationFields < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_fields, :request_path, :string
    add_column :verification_fields, :response_path, :string
  end
end
