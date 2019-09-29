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
    t("admin.verification.fields.handlers.name.#{handler}")
  end
end
