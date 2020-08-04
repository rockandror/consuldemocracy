class RemoveFieldFromLegislationProcess < ActiveRecord::Migration
  def change
    remove_column :legislation_processes, :member_type_id
  end
end
