class CreateAdminSures < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_sures do |t|
      t.references :users, foreign_key: :true
    end
  end
end
