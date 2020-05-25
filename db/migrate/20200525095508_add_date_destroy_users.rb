class AddDateDestroyUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :date_hide, :date
  end
end
