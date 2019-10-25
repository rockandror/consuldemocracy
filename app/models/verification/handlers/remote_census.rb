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

    def is_match_verification_required?
      field_assignments_to_match.any?
    end

    def field_assignments_to_match
      Verification::Field::Assignment.by_handler("remote_census").with_response_path
    end

    def get_response_value(response, assignment)
      response.extract_value(assignment.response_path)
    end

    def allowed_age?(response, attributes)
      return true unless is_age_verifcation_required?

      assignment = field_represent_min_age_to_participate.first
      birth_date = get_response_value(response, assignment)
      Age.in_years(Date.parse(birth_date)) >= User.minimum_required_age
    end

    def update_user_with_geozone(response, attributes)
      return if field_respresent_geozone.blank?

      update_user(response, field_respresent_geozone.first, attributes)
    end

    def update_user(response, assignment, attributes)
      response_value = get_response_value(response, assignment)
      geozone = get_geozone(response_value)
      user = attributes[:user]

      user.update!(geozone: geozone)
    end
end
