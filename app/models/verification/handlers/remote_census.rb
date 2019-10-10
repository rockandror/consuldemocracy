class Verification::Handlers::RemoteCensus < Verification::Handler
  register_as :remote_census

  def verify(attributes)
    response = VerificationCensusApi.new.call(attributes.except(:user))
    if verified_user?(response, attributes)
      update_user_with_geozone(response, attributes)
      successful_response(attributes)
    else
      error_response(attributes)
    end
  end

  private

    def verified_user?(response, attributes)
      response.valid? && verification_sended_fields_with_response(response, attributes)
    end

    def verification_sended_fields_with_response(response, attributes)
      attributes.except(:user).each do |attribute|
        field = get_field(attribute)
        assignment = get_remote_census_assignment(field)
        return false if unverify_attribute(response, attribute, attributes, field, assignment)
      end
      return true
    end

    def get_field(attribute)
      Verification::Field.find_by(name: attribute.first)
    end

    def get_remote_census_assignment(field)
      field.assignments.by_handler(:remote_census).first
    end

    def has_response_path?(assignment)
      assignment.present? && assignment.response_path.present?
    end

    def unverify_attribute(response, attribute, attributes, field, assignment)
      return false unless has_response_path?(assignment)

      response_value = get_response_value(response, assignment)
      sended_value = get_sended_value(attributes, field)

      return true if invalid_expected_value?(response_value, sended_value, field) ||
                      invalid_age_to_participate?(field, response_value)
    end

    def get_response_value(response, assignment)
      response.extract_value(assignment.response_path)
    end

    def get_sended_value(attributes, field)
      attributes[field.name.to_sym]
    end

    def invalid_expected_value?(response_value, sended_value, field)
      return false unless field.visible?
      response_value != sended_value
    end

    def invalid_age_to_participate?(field, response_value)
      return false unless field.represent_min_age_to_participate?
      Age.in_years(Date.parse(response_value)) <  User.minimum_required_age
    end

    def update_user_with_geozone(response, attributes)
      geozone_field = calculate_geozone_field(attributes)
      if geozone_field.present?
        assignment = get_remote_census_assignment(geozone_field)
        if has_response_path?(assignment)
          update_user(response, assignment, attributes)
        end
      end
    end

    def calculate_geozone_field(attributes)
      field = Verification::Field.find_by(represent_geozone: true)
      if field.present?
        field_assignment = field.assignments.by_handler(:remote_census).first
        return field if field_assignment.present? && field.represent_geozone?
      end
      return false
    end

    def update_user(response, assignment, attributes)
      response_value = get_response_value(response, assignment)
      user = get_user(attributes)
      geozone = get_geozone(response_value)

      user.update(geozone: geozone)
    end

    def get_user(attributes)
      User.find(attributes[:user][:id])
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
