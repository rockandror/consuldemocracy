class AddColumTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :confirmed_hide_at, :datetime
  end
end
