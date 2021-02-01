class AddColumSuresCardPosition < ActiveRecord::Migration[5.0]
  def change
    add_column :sures_customize_cards, :position_image, :string, default: 'left'
  end
end
