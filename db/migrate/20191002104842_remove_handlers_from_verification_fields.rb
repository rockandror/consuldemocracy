class RemoveHandlersFromVerificationFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :verification_fields, :handlers
  end
end
