class CreateSuresCustomizeCards < ActiveRecord::Migration[5.0]
  def change
    create_table :sures_customize_cards do |t|
      t.string :link_url
      t.boolean :header, default: false
      t.timestamps null: false
    end

    add_reference :sures_customize_cards, :site_customization_page, index: true
    add_column :sures_customize_cards, :columns, :integer, default: 4
  end
end
