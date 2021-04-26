class AddCodeProfiles < ActiveRecord::Migration[5.0]
  def up
    add_column :profiles, :code, :string
  end

  def down
    remove_column :profiles, :code
  end
end
