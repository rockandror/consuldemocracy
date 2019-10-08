class RemoveIsCheckboxFieldFromVerificationFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :verification_fields, :is_checkbox
  end
end
