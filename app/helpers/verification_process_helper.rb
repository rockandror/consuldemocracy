module VerificationProcessHelper
  def checkbox_label(field)
    return field.label if field.checkbox_link.blank?

    slug = field.checkbox_link
    custom_page = SiteCustomization::Page.find_by(slug: slug)
    "#{field.label} (#{link_to('link', custom_page.url, target: '_blank')})".html_safe
  end
end
