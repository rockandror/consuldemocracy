locale = I18n.default_locale

unless SiteCustomization::ContentBlock.find_by(locale: locale, name: "top_links")
  I18n.with_locale(locale) do
    SiteCustomization::ContentBlock.create!(
      locale: locale,
      name: "top_links",
      body: Rails.application.config.sites.map do |name, url|
        "<li><a href=\"#{url}\">#{I18n.t("sites.#{name}")}</a></li>"
      end.join
    )
  end
end
