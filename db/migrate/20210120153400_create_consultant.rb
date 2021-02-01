class CreateConsultant < ActiveRecord::Migration[5.0]
  def change
    create_table :consultants do |t|
      t.references :users, foreign_key: :true
    end
  end
end
