class AddOrderToPollAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_answers, :order, :integer
  end
end
