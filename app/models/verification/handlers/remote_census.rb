class Verification::Handlers::RemoteCensus < Verification::Handler
  register_as :remote_census

  def verify(attributes)
    if verified_user?(attributes.except(:user))
      successful_response(attributes)
    else
      error_response(attributes)
    end
  end

  private

    def verified_user?(attributes)
      response = VerificationCensusApi.new.call(attributes)

      verification_response_fields(response, attributes) if response.valid?
    end

    def verification_response_fields(response, attributes)
      attributes.each do |attribute|
        field = Verification::Field.find_by(name: attribute.first)
        field_assignment = field.assignments.by_handler(:remote_census).first
        if field_assignment.response_path.present?
          path_value = field_assignment.response_path
          return false if response.extract_value(path_value) != attributes[field.name.to_sym]
        end
      end
      return true
    end

    def successful_response(attributes)
      Verification::Handlers::Response.new true,
                                           I18n.t("verification.handlers.remote_census.verify.success"),
                                           attributes,
                                           nil
    end

    def error_response(attributes)
      Verification::Handlers::Response.new false,
                                           I18n.t("verification.handlers.remote_census.verify.error"),
                                           attributes,
                                           nil
    end
end
