class AddsVotableCacheScoreFieldToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :cached_votes_score, :integer, default: 0

    add_index :topics, :cached_votes_score
  end
end
