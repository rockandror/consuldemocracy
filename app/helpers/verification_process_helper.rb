module VerificationProcessHelper

  def checkbox_label(field)
    label = field.label
    if field.checkbox_link.present?
      slug = field.checkbox_link
      custom_page = SiteCustomization::Page.find_by(slug: slug)
      label += "(#{link_to('link', custom_page.url, target: '_blank')})"
    end
    label.html_safe
  end
end
