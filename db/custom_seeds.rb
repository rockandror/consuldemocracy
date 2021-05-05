locale = I18n.default_locale

unless SiteCustomization::ContentBlock.find_by(locale: locale, name: "top_links")
  I18n.with_locale(locale) do
    SiteCustomization::ContentBlock.create!(
      locale: locale,
      name: "top_links",
      body: %Q(
        <li>
          <a href="https://www.gobiernodecanarias.org/">
            #{I18n.t("sites.open_government")}
          </a>
        </li>
        <li>
          <a href="https://www.gobiernodecanarias.org/transparencia/">
            #{I18n.t("sites.transparency")}
          </a>
        </li>
        <li>
          <a href="https://datos.canarias.es/">
            #{I18n.t("sites.open_data")}
          </a>
        </li>
        <li>
          <a href="https://www.gobiernodecanarias.org/participacionciudadana/
">
            #{I18n.t("sites.citizen_participation")}
          </a>
        </li>
      )
    )
  end
end
