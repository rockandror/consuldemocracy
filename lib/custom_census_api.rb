include DocumentParser
class CustomCensusApi

  def call(document_type, document_number, date_of_birth)
    response = nil
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant, date_of_birth))
      return response if response.valid?
    end
    response
  end

  # Setting["remote_census_response.date_of_birth"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.fecha_nacimiento_string"
  # alias_date_of_birth = Setting["remote_census_response.date_of_birth"]
  # alias_date_of_birth_sym = alias_date_of_birth.split(".").map { |part| part.to_sym } if alias_date_of_birth.present?
  # Setting["remote_census_response.postal_code"] = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_postal"
  # alias_postal_code = Setting["remote_census_response.postal_code"]
  # alias_postal_code_sym = alias_postal_code.split(".").map { |part| part.to_sym } if alias_postal_code.present?
  # Setting["remote_census_response.district"] = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_distrito"
  # alias_district = Setting["remote_census_response.district"]
  # alias_district_sym = alias_district.split(".").map { |part| part.to_sym } if alias_district.present?
  # Setting["remote_census_response.gender"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.descripcion_sexo"
  # alias_gender = Setting["remote_census_response.gender"]
  # alias_gender_sym = alias_gender.split(".").map { |part| part.to_sym } if alias_gender.present?
  # Setting["remote_census_response.name"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.nombre"
  # alias_name = Setting["remote_census_response.name"]
  # alias_name_sym = alias_name.split(".").map { |part| part.to_sym } if alias_name.present?
  # Setting["remote_census_response.surname"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.apellido1"
  # alias_surname = Setting["remote_census_response.surname"]
  # alias_surname_sym = alias_surname.split(".").map { |part| part.to_sym } if alias_surname.present?
  # Setting["remote_census_response.valid"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
  # alias_valid = Setting["remote_census_response.valid"]
  # alias_valid_sym = alias_valid.split(".").map { |part| part.to_sym } if alias_valid.present?

  class Response
    def initialize(body)
      @body = body
    end

    # def valid?
    #   data[:datos_habitante][:item].present?
    # end
    def valid?
      alias_valid = Setting["remote_census_response.valid"]
      alias_valid_sym = alias_valid.split(".").map { |part| part.to_sym } if alias_valid.present?
      @body.dig(*alias_valid_sym).present?
    end

    # def date_of_birth
    #   str = data[:datos_habitante][:item][:fecha_nacimiento_string]
    #   day, month, year = str.match(/(\d\d?)\D(\d\d?)\D(\d\d\d?\d?)/)[1..3]
    #   return nil unless day.present? && month.present? && year.present?
    #   Time.zone.local(year.to_i, month.to_i, day.to_i).to_date
    # end
    def date_of_birth
      alias_date_of_birth = Setting["remote_census_response.date_of_birth"]
      alias_date_of_birth_sym = alias_date_of_birth.split(".").map { |part| part.to_sym } if alias_date_of_birth.present?
      str = @body.dig(*alias_date_of_birth_sym)
      day, month, year = str.match(/(\d\d?)\D(\d\d?)\D(\d\d\d?\d?)/)[1..3]
      return nil unless day.present? && month.present? && year.present?
      Time.zone.local(year.to_i, month.to_i, day.to_i).to_date
    end

    # def postal_code
    #   data[:datos_vivienda][:item][:codigo_postal]
    # end
    def postal_code
      alias_postal_code = Setting["remote_census_response.postal_code"]
      alias_postal_code_sym = alias_postal_code.split(".").map { |part| part.to_sym } if alias_postal_code.present?
      @body.dig(*alias_postal_code_sym)
    end

    # def district_code
    #   data[:datos_vivienda][:item][:codigo_distrito]
    # end
    def district_code
      alias_district = Setting["remote_census_response.district"]
      alias_district_sym = alias_district.split(".").map { |part| part.to_sym } if alias_district.present?
      @body.dig(*alias_district_sym)
    end

    # def gender
    #   case data[:datos_habitante][:item][:descripcion_sexo]
    #   when "Varón"
    #     "male"
    #   when "Mujer"
    #     "female"
    #   end
    # end
    def gender
      alias_gender = Setting["remote_census_response.gender"]
      alias_gender_sym = alias_gender.split(".").map { |part| part.to_sym } if alias_gender.present?

      case @body.dig(*alias_gender_sym)
      when "Varón"
        "male"
      when "Mujer"
        "female"
      end
    end

    # def name
    #   "#{data[:datos_habitante][:item][:nombre]} #{data[:datos_habitante][:item][:apellido1]}"
    # end
    def name
      alias_name = Setting["remote_census_response.name"]
      alias_name_sym = alias_name.split(".").map { |part| part.to_sym } if alias_name.present?

      alias_surname = Setting["remote_census_response.surname"]
      alias_surname_sym = alias_surname.split(".").map { |part| part.to_sym } if alias_surname.present?

      "#{@body.dig(*alias_name_sym)} #{@body.dig(*alias_surname_sym)}"
    end

    private

      def data
        @body[:get_habita_datos_response][:get_habita_datos_return]
      end
  end

  private

    def get_response_body(document_type, document_number, date_of_birth)
      if end_point_available?
        # client.call(:get_habita_datos, message: request(document_type, document_number)).body
        client.call(Setting["remote_census_request.method_name"].to_sym, message: request(document_type, document_number, date_of_birth)).body
      else
        stubbed_response(document_type, document_number)
      end
    end

    def client
      @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
    end

    # def request(document_type, document_number)
    #   { request:
    #     { codigo_institucion: Rails.application.secrets.census_api_institution_code,
    #       codigo_portal:      Rails.application.secrets.census_api_portal_name,
    #       codigo_usuario:     Rails.application.secrets.census_api_user_code,
    #       documento:          document_number,
    #       tipo_documento:     document_type,
    #       codigo_idioma:      102,
    #       nivel: 3 }}
    # end

    def request(document_type, document_number, date_of_birth)
      structure = eval(Setting["remote_census_request.structure"])

      alias_document_type = Setting["remote_census_request.alias_document_type"]
      alias_document_number = Setting["remote_census_request.alias_document_number"]
      alias_date_of_birth = Setting["remote_census_request.alias_date_of_birth"]

      alias_document_type_sym = alias_document_type.split(".").map{ |part| part.to_sym } if alias_document_type.present?
      alias_document_number_sym = alias_document_number.split(".").map{ |part| part.to_sym } if alias_document_number.present?
      alias_date_of_birth_sym = alias_date_of_birth.split(".").map{ |part| part.to_sym } if alias_date_of_birth.present?

      deep_set(structure, alias_document_type_sym, document_type) if alias_document_type.present?
      deep_set(structure, alias_document_number_sym, document_number) if alias_document_number.present?
      deep_set(structure, alias_date_of_birth_sym, date_of_birth) if alias_date_of_birth.present?

      structure
    end

    def deep_set(hash, path, value)
      *path, final_key = path
      to_set = path.empty? ? hash : hash.dig(*path)

      return unless to_set
      to_set[final_key] = value
    end

    def end_point_available?
      Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
    end

    def stubbed_response(document_type, document_number)
      if (document_number == "12345678Z" || document_number == "12345678Y") && document_type == "1"
        stubbed_valid_response
      else
        stubbed_invalid_response
      end
    end

    def stubbed_valid_response
      {
        get_habita_datos_response: {
          get_habita_datos_return: {
            datos_habitante: {
              item: {
                fecha_nacimiento_string: "31-12-1980",
                identificador_documento: "12345678Z",
                descripcion_sexo: "Varón",
                nombre: "José",
                apellido1: "García"
              }
            },
            datos_vivienda: {
              item: {
                codigo_postal: "28013",
                codigo_distrito: "01"
              }
            }
          }
        }
      }
    end

    def stubbed_invalid_response
      {get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {}, datos_vivienda: {}}}}
    end

    def dni?(document_type)
      document_type.to_s == "1"
    end

end
