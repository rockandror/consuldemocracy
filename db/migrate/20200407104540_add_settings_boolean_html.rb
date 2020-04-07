class AddSettingsBooleanHtml < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :permit_html_safe, :boolean, :default => false
  end
end
