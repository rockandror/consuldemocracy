module VerificationProcessHelper

  def checkbox_label(field)
    "#{field.label} (#{link_to("link", SiteCustomization::Page.find_by(slug: field.checkbox_link).url, target: "_blank")})".html_safe
  end
end
