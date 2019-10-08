module VerificationProcessHelper

  def checkbox_label(field)
    label = "#{field.label}"
    label += "(#{link_to("link", SiteCustomization::Page.find_by(slug: field.checkbox_link).url, target: "_blank")})".html_safe if field.checkbox_link.present?
  end
end
