module VerificationProcessHelper
  def checkbox_label(field)
    return field.label if field.checkbox_link.blank?

    slug = field.checkbox_link
    custom_page = SiteCustomization::Page.find_by(slug: slug)
    "#{field.label} (#{link_to('link', custom_page.url, target: '_blank')})".html_safe
  end

  def process_field_name(field)
    "#{field.name}_confirmation"
  end

  def process_field_label(field)
    t("verification.process.form.confirmation_label", original_label: field.label)
  end

  def process_field_hint(field)
    t("verification.process.form.confirmation_hint", original_label: field.label.downcase)
  end
end
