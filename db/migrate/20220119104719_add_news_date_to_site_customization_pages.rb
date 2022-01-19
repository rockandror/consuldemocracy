class AddNewsDateToSiteCustomizationPages < ActiveRecord::Migration[5.2]
  def change
    add_column :site_customization_pages, :news_date, :timestamp
    SiteCustomization::Page.where(is_news: true).update_all("news_date=created_at")
  end
end
