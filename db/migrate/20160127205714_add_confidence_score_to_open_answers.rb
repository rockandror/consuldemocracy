class AddConfidenceScoreToOpenAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :open_answers, :confidence_score, :integer, default: 0
  end
end
