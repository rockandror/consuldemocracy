class Verification::Handlers::Resident < Verification::Handler
  register_as :residents

  def verify(attributes)
    resident = get_resident(attributes.except(:user))

    if verified?(resident)
      update_user_with_geozone(resident, attributes)
      successful_response(attributes)
    else
      error_response(attributes)
    end
  end

  private

    def get_resident(attributes)
      Verification::Resident.find_by_data(attributes)
    end

    def verified?(resident)
      resident.present? && allowed_age?(resident)
    end

    def allowed_age?(resident)
      return true unless is_age_verifcation_required?

      name = field_represent_min_age_to_participate.first.verification_field.name
      birth_date = resident.data[name]
      Age.in_years(Date.parse(birth_date)) >= User.minimum_required_age
    end

    def is_age_verifcation_required?
      field_represent_min_age_to_participate.any?
    end

    def field_represent_min_age_to_participate
      field_assignments_to_match.joins(:verification_field).where("verification_fields.represent_min_age_to_participate": true)
    end

    def field_assignments_to_match
      Verification::Field::Assignment.by_handler("residents")
    end

    def update_user_with_geozone(resident, attributes)
      return if field_respresent_geozone.blank?

      update_user(resident, attributes)
    end

    def field_respresent_geozone
      field_assignments_to_match.joins(:verification_field).where("verification_fields.represent_geozone": true)
    end

    def update_user(resident, attributes)
      name = field_respresent_geozone.first.verification_field.name
      resident_geozone = resident.data[name]
      geozone = get_geozone(resident_geozone)
      user = attributes[:user]

      user.update(geozone: geozone)
    end

    def get_geozone(response_value)
      Geozone.where(census_code: response_value).first
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
