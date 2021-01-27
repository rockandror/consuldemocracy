class CreateSuresCustomizeCardTranslations < ActiveRecord::Migration[5.0]
  def self.up
    Sures::CustomizeCard.create_translation_table!(
      {
        label:       :string,
        title:       :string,
        description: :text,
        link_text:   :string
      },
      { migrate_data: true }
    )
  end

  def self.down
    Sires::CustomizeCard.drop_translation_table!
  end
end
