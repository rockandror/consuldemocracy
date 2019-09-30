class AddHintToVerificationFields < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        add_column :verification_fields, :hint, :string
        Verification::Field.add_translation_fields! hint: :string
      end

      dir.down do
        remove_column :verification_fields, :hint
        remove_column :verification_field_translations, :hint
      end
    end
  end
end
