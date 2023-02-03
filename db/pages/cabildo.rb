def generate_content(page)
  page.title = I18n.t("pages.main_links.cabildo_title")
  page.save!
end
if SiteCustomization::Page.find_by(slug: "_cabildo_que-es-el-cabildo-abierto").nil?
  page = SiteCustomization::Page.new(slug: "_cabildo_que-es-el-cabildo-abierto", status: "published")
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) { generate_content(page) }
  end
end
