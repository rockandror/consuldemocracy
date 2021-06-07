class AddIsNewsToSiteCustomizationPages < ActiveRecord::Migration[5.2]
  def up
    add_column :site_customization_pages, :is_news, :boolean, default: false
  end
end
