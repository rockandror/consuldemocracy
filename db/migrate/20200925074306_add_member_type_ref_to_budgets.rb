class AddMemberTypeRefToBudgets < ActiveRecord::Migration
  def change
    add_reference :budgets, :member_type, index: true, foreign_key: true
  end
end
