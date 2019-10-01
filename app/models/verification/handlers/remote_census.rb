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
      Verification::Field.with_response_path.each do |field|
        path_value = field.response_path
        return false if response.extract_value(path_value) != attributes[field.name.to_sym]
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
