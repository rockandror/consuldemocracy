def generate_content(page)
  page.title = I18n.t("pages.main_links.participation_title")
  page.save!
end
if SiteCustomization::Page.find_by(slug: "_participacion_que-hacemos").nil?
  page = SiteCustomization::Page.new(slug: "_participacion_que-hacemos", status: "published")
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) { generate_content(page) }
  end
end
