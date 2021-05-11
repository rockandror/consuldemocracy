class ChangeColumnNameUsers < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :name, :first_name
  end
end
