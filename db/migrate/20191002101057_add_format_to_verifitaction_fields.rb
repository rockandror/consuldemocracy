class AddFormatToVerifitactionFields < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_fields, :format, :string
  end
end
