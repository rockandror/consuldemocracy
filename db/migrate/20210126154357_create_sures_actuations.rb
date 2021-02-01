class CreateSuresActuations < ActiveRecord::Migration[5.0]
  def change
    create_table :sures_actuations do |t|
      t.string :proposal_title
      t.text :proposal_objective
      t.string :territorial_scope
      t.string :location_performance
      t.string :technical_visibility
      t.string :actions_taken
      t.string :status
      t.string :financig_performance
      t.boolean :check_anno, default: false
      t.boolean :cechk_multianno, default: false
      t.string :annos
      t.string :tracking

      t.timestamps
    end
  end
end
