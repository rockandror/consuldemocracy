if SiteCustomization::Page.find_by_slug("accessibility").nil?
  page = SiteCustomization::Page.new(slug: "accessibility", status: "published")
  page.title = "Accesibilidad"
  page.content = File.read Rails.root.join("db","pages","custom","html","accessibility.html")
  page.save!
end
