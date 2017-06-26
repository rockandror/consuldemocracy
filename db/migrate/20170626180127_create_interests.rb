class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.references :user, index: true, foreign_key: true
      t.references :interestable, polymorphic: true, index: true

      t.timestamps null: false
    end

    add_index :interests, [:user_id, :interestable_type, :interestable_id], name: "access_interests"
  end
end
