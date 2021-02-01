class AddActiveFieldSearchSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :sures_search_settings, :active, :boolean, default: true
  end
end
