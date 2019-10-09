module VerificationFieldsHelper
  def field_handlers
    Verification::Configuration.available_handlers
  end

  def field_handler_enabled?(field, handler)
    field.handlers.present? ? field.handlers.include?(handler.to_s) : false
  end

  def field_handler_id(handler)
    "verification_field_handlers_#{handler}"
  end

  def handlers_text_representation(field)
    translations = []
    field.handlers.each_with_object(translations) do |handler, translations|
      translations << handler_text_representation(handler)
    end
    translations.sort
  end

  def handler_text_representation(handler)
    t("admin.wizards.verification.fields.handlers.name.#{handler}")
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
