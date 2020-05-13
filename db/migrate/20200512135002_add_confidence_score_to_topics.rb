class AddConfidenceScoreToTopics < ActiveRecord::Migration[5.0]
  def change
    add_column :topics, :confidence_score, :integer, default: 0
    add_index :topics, :confidence_score
  end
end
