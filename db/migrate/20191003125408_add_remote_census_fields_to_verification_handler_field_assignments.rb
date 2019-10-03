class AddRemoteCensusFieldsToVerificationHandlerFieldAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_handler_field_assignments, :request_path, :string
    add_column :verification_handler_field_assignments, :response_path, :string
  end
end
