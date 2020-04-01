class AddPermitTextProccess < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :permit_text_proposals, :boolean
  end
end
