class ChangeProfileUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :profiles

    add_reference :users, :profiles, index: :true, foreign_key: true
  end
end
