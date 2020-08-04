if SiteCustomization::Page.find_by(slug: "faq").nil?
  page = SiteCustomization::Page.new(slug: "faq", status: "published")
  page.title = I18n.t("pages.help.faq.page.title")
  page.more_info_flag = true
  page.content = "<p>#{I18n.t("pages.help.faq.page.description")}</p>"
  page.save!
end
