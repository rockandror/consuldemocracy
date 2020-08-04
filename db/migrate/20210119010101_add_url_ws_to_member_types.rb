class AddUrlWsToMemberTypes < ActiveRecord::Migration
  def change
    add_column :member_types, :url_ws, :string
  end
end
