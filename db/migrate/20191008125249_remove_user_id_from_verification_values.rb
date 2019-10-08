class RemoveUserIdFromVerificationValues < ActiveRecord::Migration[5.0]
  def change
    remove_column :verification_values, :user_id, :integer
  end
end
