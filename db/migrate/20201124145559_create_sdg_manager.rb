class CreateSDGManager < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_managers do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
