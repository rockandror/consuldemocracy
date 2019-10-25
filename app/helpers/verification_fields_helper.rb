module VerificationFieldsHelper
  def handlers_text_representation(field)
    field.handlers.each_with_object([]) do |handler, translations|
      translations << handler_text_representation(handler)
    end.sort
  end

  def handler_text_representation(handler)
    t("admin.wizards.verification.fields.field.handlers.#{handler}")
  end

  def field_hint(field)
    field.hint || false
  end

  def verification_fields_no_results_message
    t("admin.wizards.verification.fields.index.no_results_html",
      link: link_to(t("admin.wizards.verification.fields.index.create_first"),
                    new_admin_wizards_verification_field_path))
  end

  def verification_fields_no_fields_defined
    t("admin.wizards.verification.finish.no_fields_defined_html",
      link: link_to(t("admin.wizards.verification.finish.skip_user_verification"),
                    new_admin_wizards_verification_path))
  end
end
