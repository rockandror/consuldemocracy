class RenameVerificationHandlerFieldAssignmentsToVerificationFieldAssignments < ActiveRecord::Migration[5.0]
  def change
    rename_table :verification_handler_field_assignments, :verification_field_assignments
  end
end
