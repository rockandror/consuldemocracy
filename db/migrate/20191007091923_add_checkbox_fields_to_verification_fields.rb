class AddCheckboxFieldsToVerificationFields < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_fields, :is_checkbox, :boolean
    add_column :verification_fields, :checkbox_link, :string
  end
end
