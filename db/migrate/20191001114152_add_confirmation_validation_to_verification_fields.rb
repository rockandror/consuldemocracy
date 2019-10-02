class AddConfirmationValidationToVerificationFields < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_fields, :confirmation_validation, :boolean
  end
end
