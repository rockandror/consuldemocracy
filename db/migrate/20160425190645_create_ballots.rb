class CreateBallots < ActiveRecord::Migration[4.2]
  def change
    create_table :ballots do |t|
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
