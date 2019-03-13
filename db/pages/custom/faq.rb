if SiteCustomization::Page.find_by_slug("faq").nil?
  page = SiteCustomization::Page.new(slug: "faq", status: "published")
  page.title = "Soluciones a problemas técnicos (FAQ)"
  page.content = File.read Rails.root.join("db","pages","custom","html","faq.html")
  page.save!
end
