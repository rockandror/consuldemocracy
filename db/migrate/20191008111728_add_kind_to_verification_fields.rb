class AddKindToVerificationFields < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_fields, :kind, :integer
  end
end
