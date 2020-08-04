class RemoveFieldFromPoll < ActiveRecord::Migration
  def change
    remove_column :polls, :member_type_id
  end
end
