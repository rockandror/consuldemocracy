class CreateJoinTableMemberTypePoll < ActiveRecord::Migration
  def change
    create_join_table :MemberTypes, :Polls do |t|
      t.index [:member_type_id, :poll_id], name: 'index_member_type_id_and_poll_id'
      t.index [:poll_id, :member_type_id], name: 'index_poll_id_and_member_type_id'
    end
  end
end
