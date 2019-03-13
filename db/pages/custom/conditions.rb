if SiteCustomization::Page.find_by_slug("conditions").nil?
  page = SiteCustomization::Page.new(slug: "conditions", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("pages.conditions.title")
  page.subtitle = "AVISO LEGAL SOBRE LAS CONDICIONES DE USO, PRIVACIDAD Y PROTECCIÓN DE DATOS " \
                  "PERSONALES DEL PORTAL DE GOBIERNO ABIERTO DEL AYUNTAMIENTO DE MADRID"
  page.content = File.read Rails.root.join("db","pages","custom","html","conditions.html")
  page.save!
end
