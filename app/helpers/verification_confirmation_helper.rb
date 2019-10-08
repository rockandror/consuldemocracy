module VerificationConfirmationHelper
  def confirmation_field_label(field)
    case field
    when "sms_confirmation_code"
      t("verification.confirmation.form.fields.sms_confirmation_code.label")
    end
  end

  def confirmation_field_hint(field)
    case field
    when "sms_confirmation_code"
      t("verification.confirmation.form.fields.sms_confirmation_code.hint")
    end
  end
end
