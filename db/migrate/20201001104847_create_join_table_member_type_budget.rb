class CreateJoinTableMemberTypeBudget < ActiveRecord::Migration
  def change
    create_join_table :MemberTypes, :Budgets do |t|
      t.index [:member_type_id, :budget_id], name: 'index_member_type_id_and_budget_id'
      t.index [:budget_id, :member_type_id], name: 'index_budget_id_and_member_type_id'
    end
  end
end
