class AddAcceptedDelegationAlertToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :accepted_delegation_alert, :boolean, default: false
  end
end
