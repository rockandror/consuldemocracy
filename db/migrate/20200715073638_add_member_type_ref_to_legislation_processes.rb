class AddMemberTypeRefToLegislationProcesses < ActiveRecord::Migration
  def change
    add_reference :legislation_processes, :member_type, index: true, foreign_key: true
  end
end
