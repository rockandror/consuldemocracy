if SiteCustomization::Page.find_by_slug("privacy").nil?
  page = SiteCustomization::Page.new(slug: "privacy", status: "published")
  page.print_content_flag = true
  page.title = "Política de Privacidad"
  page.subtitle = "AVISO DE PROTECCIÓN DE DATOS"
  page.content = File.read Rails.root.join("db","pages","custom","html","privacy.html")
  page.save!
end
