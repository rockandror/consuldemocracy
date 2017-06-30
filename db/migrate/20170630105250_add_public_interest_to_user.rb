class AddPublicInterestToUser < ActiveRecord::Migration
  def change
    add_column :users, :public_interest, :boolean, default: false
  end
end
