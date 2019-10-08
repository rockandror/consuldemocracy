class Admin::Verification::Handlers::Sms::FieldsController < Admin::Verification::BaseController

  RECOMMENDED_FIELD_ATTRIBUTES = {
    label: I18n.t("admin.verification.handlers.sms.fields.create.phone_default_label"),
    confirmation_validation: true,
    required: true
  }

  def create
    create_default_handler_settings
    notice = t("admin.verification.handlers.sms.fields.create.notice")
    redirect_to admin_wizards_verification_handler_field_assignments_path(handler_id),
      notice: notice
  end

  private

    def create_default_handler_settings
      field = Verification::Field.find_or_create_by(name: "phone")
      field.update(RECOMMENDED_FIELD_ATTRIBUTES.merge(position: next_position))

      Verification::Handler::FieldAssignment.find_or_create_by(verification_field: field, handler: handler_id)
    end

    def next_position
      max_position = Verification::Field.maximum(:position)
      max_position.is_a?(Integer) ? max_position + 1 : 1
    end

    def handler_id
      Verification::Handlers::Sms.id
    end
end
