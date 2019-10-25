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

    def field_assignments_to_match
      Verification::Field::Assignment.by_handler("residents")
    end

    def update_user_with_geozone(resident, attributes)
      return if field_respresent_geozone.blank?

      update_user(resident, attributes)
    end

    def update_user(resident, attributes)
      name = field_respresent_geozone.first.verification_field.name
      resident_geozone = resident.data[name]
      geozone = get_geozone(resident_geozone)
      user = attributes[:user]

      user.update!(geozone: geozone)
    end
end
