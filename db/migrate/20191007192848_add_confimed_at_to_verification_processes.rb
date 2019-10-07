class AddConfimedAtToVerificationProcesses < ActiveRecord::Migration[5.0]
  def change
    add_column :verification_processes, :confirmed_at, :datetime
  end
end
