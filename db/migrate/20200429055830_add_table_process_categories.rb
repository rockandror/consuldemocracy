class AddTableProcessCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :legislation_categories do |t|
      t.text :name 
      t.text :tag
      t.references :legislation_process, index: true, foreign_key: true
      

      t.timestamps null: false
    end
  end
end
