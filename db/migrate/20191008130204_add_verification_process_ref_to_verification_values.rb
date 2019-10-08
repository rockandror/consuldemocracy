class AddVerificationProcessRefToVerificationValues < ActiveRecord::Migration[5.0]
  def change
    add_reference :verification_values, :verification_process, foreign_key: true
  end
end
