require "rails_helper"

describe "Admin custom pages", :admin do
  context "Index" do
    scenario "should contain all default custom pages published populated by db:seeds" do
      slugs = %w[_cabildo_que-es-el-cabildo-abierto _etica_codigo-de-buen-gobierno-y-seguimiento
                 _participacion_que-hacemos accessibility conditions faq privacy
                 welcome_not_verified welcome_level_two_verified welcome_level_three_verified]

      expect(SiteCustomization::Page.count).to be 10
      slugs.each do |slug|
        expect(SiteCustomization::Page.find_by(slug: slug).status).to eq "published"
      end

      visit admin_site_customization_pages_path

      expect(all("[id^='site_customization_page_']").count).to be 10
      slugs.each do |slug|
        expect(page).to have_content slug
      end
    end
  end
end
