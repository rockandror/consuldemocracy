class AddFormatToVerificationHandlerFieldAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_handler_field_assignments, :format, :string
  end
end
