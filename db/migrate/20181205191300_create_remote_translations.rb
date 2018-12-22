class CreateRemoteTranslations < ActiveRecord::Migration
  def change
    create_table :remote_translations do |t|
      t.string :from
      t.string :to
      t.integer :remote_translatable_id
      t.string  :remote_translatable_type

      t.timestamps null: false
    end
  end
end
