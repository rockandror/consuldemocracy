namespace :pages do
  desc "Create and update custom pages"
  task create_and_update_custom_pages: :environment do
    slugs = %W[welcome_not_verified welcome_level_two_verified welcome_level_three_verified]
    slugs.each do |slug|
      SiteCustomization::Page.find_by(slug: slug)&.destroy
      load Rails.root.join("db", "pages", "#{slug}.rb")
    end
    load Rails.root.join("db", "pages", "census_terms.rb")
  end
end
