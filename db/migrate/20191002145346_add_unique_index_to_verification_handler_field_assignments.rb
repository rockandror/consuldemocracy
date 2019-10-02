class AddUniqueIndexToVerificationHandlerFieldAssignments < ActiveRecord::Migration[5.0]
  def change
    add_index :verification_handler_field_assignments, [:verification_field_id, :handler], unique: true, name: "unique_index_to_handler_and_verification_field_id"
  end
end
