class RemoveVisitIdFromDebates < ActiveRecord::Migration[6.1]
  def change
    remove_column :debates, :visit_id, :string
  end
end
