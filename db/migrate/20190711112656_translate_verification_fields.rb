class TranslateVerificationFields < ActiveRecord::Migration[5.0]
  def self.up
    Verification::Field.create_translation_table!({
      :label => :string,
    }, {
      :migrate_data => true,
      :remove_source_columns => false
    })
  end

  def self.down
    Verification::Field.drop_translation_table! :migrate_data => true
  end
end
