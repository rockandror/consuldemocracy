class Verification::Handlers::Resident < Verification::Handler
  register_as :residents

  def verify(attributes)
    if match_found?(attributes.except(:user))
      successful_response(attributes)
    else
      error_response(attributes)
    end
  end

  private

    def match_found?(attributes)
      Verification::Resident.find_by_data(attributes).present?
    end

    def successful_response(attributes)
      Verification::Handlers::Response.new true,
                                           I18n.t("verification.handlers.resident.verify.success"),
                                           attributes,
                                           nil
    end

    def error_response(attributes)
      Verification::Handlers::Response.new false,
                                           I18n.t("verification.handlers.resident.verify.error"),
                                           attributes,
                                           nil
    end
end
