class AddFlagsTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :flags_count, :integer, default: 0
    add_column :topics, :ignored_flag_at, :datetime
  end
end
