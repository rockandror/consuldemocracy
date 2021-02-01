class CreateAdresses < ActiveRecord::Migration[5.0]
  def change
    create_table :adresses do |t|
      t.references :users, foreign_key: :true
      t.text :road_type
      t.text :road_name
      t.text :road_number
      t.text :floor
      t.text :door
      t.text :gate
      t.text :district
      t.text :borought
      t.text :postal_code
      t.timestamps
    end
  end
end
