class CreateTranslateVerificationFieldOptions < ActiveRecord::Migration[5.0]
  def self.up
    Verification::Field::Option.create_translation_table!({
      :label => :string,
    }, {
      :migrate_data => true,
      :remove_source_columns => false
    })
  end

  def self.down
    Verification::Field::Option.drop_translation_table!
  end
end
