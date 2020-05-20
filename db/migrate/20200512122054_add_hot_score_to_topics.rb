class AddHotScoreToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :hot_score, :bigint, default: 0
  end
end
