class RemoveRemoteCensusFieldsFromVerificationFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :verification_fields, :request_path
    remove_column :verification_fields, :response_path
  end
end
