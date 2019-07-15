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
end
