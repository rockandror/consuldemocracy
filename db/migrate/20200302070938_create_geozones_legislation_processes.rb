class CreateGeozonesLegislationProcesses < ActiveRecord::Migration[5.0]
  def change
    drop_table(:geozones_legislation_processes, if_exists: true)

    create_table :geozones_legislation_processes do |t|
      t.references :geozone, index: true, foreign_key: true
      t.references :legislation_process, index: true, foreign_key: true
    end
  end
end
