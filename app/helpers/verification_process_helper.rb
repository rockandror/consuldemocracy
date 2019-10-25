module VerificationProcessHelper
  def checkbox_link_url(field)
    SiteCustomization::Page.find_by(slug: field.checkbox_link).url
  end

  def process_confirmation_field_name(field)
    "#{field.name}_confirmation"
  end

  def process_confirmation_field_label(field)
    t("verification.process.form.confirmation_label", original_label: field.label)
  end

  def process_confirmation_field_hint(field)
    t("verification.process.form.confirmation_hint", original_label: field.label.downcase)
  end
end
