class CreateJoinTableMemberTypeLegislationProcess < ActiveRecord::Migration
  def change
    create_join_table :MemberTypes, :LegislationProcesses do |t|
      t.index [:member_type_id, :legislation_process_id], name: 'index_member_type_id_and_legislation_process_id'
      t.index [:legislation_process_id, :member_type_id], name: 'index_legislation_process_id_and_member_type_id'
    end
  end
end
