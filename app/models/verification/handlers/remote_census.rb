class Verification::Handlers::RemoteCensus < Verification::Handler
  register_as :remote_census

  def verify(attributes)
    response = VerificationCensusApi.new.call(attributes.except(:user))

    if response.valid? && verified_user?(response, attributes)
      update_user_with_geozone(response, attributes)
      successful_response(attributes)
    else
      error_response(attributes)
    end
  end

  private

    def verified_user?(response, attributes)
      match_request_with_response_fields?(response, attributes) && allowed_age?(response, attributes)
    end

    def match_request_with_response_fields?(response, attributes)
      return true unless is_match_verification_required?

      field_assignments_to_match.each do |field_assignment|
        next unless field_assignment.verification_field.visible?

        name = field_assignment.verification_field.name.to_sym
        return false if attributes[name] != get_response_value(response, field_assignment)
      end
    end

    def allowed_age?(response, attributes)
      return true unless is_age_verifcation_required?

      assignment = field_represent_min_age_to_participate.first
      birth_date = get_response_value(response, assignment)
      Age.in_years(Date.parse(birth_date)) >= User.minimum_required_age
    end

    def is_match_verification_required?
      field_assignments_to_match.any?
    end

    def is_age_verifcation_required?
      field_represent_min_age_to_participate.any?
    end

    def field_represent_min_age_to_participate
      field_assignments_to_match.joins(:verification_field).where("verification_fields.represent_min_age_to_participate": true)
    end

    def geozone_assignments
      field_assignments_to_match.joins(:verification_field).where("verification_fields.represent_geozone": true)
    end

    def field_assignments_to_match
      Verification::Handler::FieldAssignment.by_handler("remote_census").with_response_path
    end

    def get_response_value(response, assignment)
      response.extract_value(assignment.response_path)
    end

    def update_user_with_geozone(response, attributes)
      return if geozone_assignments.blank?

      update_user(response, geozone_assignments.first, attributes)
    end

    def update_user(response, assignment, attributes)
      response_value = get_response_value(response, assignment)
      user = attributes[:user]
      geozone = get_geozone(response_value)

      user.update(geozone: geozone)
    end

    def get_geozone(response_value)
      Geozone.where(census_code: response_value).first
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
