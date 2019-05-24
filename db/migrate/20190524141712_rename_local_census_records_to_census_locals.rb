class RenameLocalCensusRecordsToCensusLocals < ActiveRecord::Migration[5.0]
  def change
    rename_table :local_census_records, :census_locals
  end
end
