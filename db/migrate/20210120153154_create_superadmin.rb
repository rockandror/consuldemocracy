class CreateSuperadmin < ActiveRecord::Migration[5.0]
  def change
    create_table :superadmins do |t|
      t.references :users, foreign_key: :true
    end
  end
end
