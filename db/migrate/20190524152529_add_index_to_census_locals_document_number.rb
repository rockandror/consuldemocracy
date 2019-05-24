class AddIndexToCensusLocalsDocumentNumber < ActiveRecord::Migration[5.0]
  def change
    add_index :census_locals, :document_number
  end
end
