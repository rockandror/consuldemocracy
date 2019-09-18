class Admin::Verification::Handlers::Sms::FieldsController < Admin::Verification::BaseController

  def create
    create_default_handler_settings
    notice = t("admin.verification.handlers.sms.create.notice")
    redirect_to admin_verification_fields_path, notice: notice
  end

  private

    def create_default_handler_settings
      Setting["feature.verification.handler.sms"] = true

      Verification::Field.create(name: :phone,
                                 label: "Mobile phone",
                                 position: Verification::Field.maximum(:position) || 1,
                                 handlers: :sms) unless Verification::Field.find_by(name: :phone)


      Verification::Field.create(name: :phone_confirmation,
                                 label: "Mobile phone confirmation",
                                 position: Verification::Field.maximum(:position),
                                 handlers: :sms) unless Verification::Field.find_by(name: :phone_confirmation)
    end
end
