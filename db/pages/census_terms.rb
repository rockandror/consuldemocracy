if SiteCustomization::Page.find_by(slug: "census_terms").nil?
  page = SiteCustomization::Page.new(slug: "census_terms", status: "published")
  page.print_content_flag = true
  page.title = "Terminos de acceso al Padrón"
  page.content = "<p>Para verificar la cuenta hay que tener 16 años o más y estar empadronado aportando los datos indicados anteriormente, los cuales serán contrastados. Aceptando el proceso de verificación acepta dar su consentimiento para contrastar dicha información, así como medios de contacto que figuren en dichos ficheros. Los datos aportados serán incorporados y tratados en un fichero indicado anteriormente en las condiciones de uso del portal.</p>"
  page.save!
end
