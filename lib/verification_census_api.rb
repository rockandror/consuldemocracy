class VerificationCensusApi

  def call(attributes)
    response = Response.new(get_response_body(attributes))
  end

  class Response
    def initialize(body)
      @body = body
    end

    def extract_value(path_value)
      path = parse_path(path_value)
      return nil unless path.present?
      @body.dig(*path)
    end

    def valid?
      path_value = Setting["remote_census.response.valid"]
      extract_value(path_value).present?
    end

    def parse_path(path_value)
      path_value.split(".").map { |section| section.to_sym } if path_value.present?
    end
  end

  private

    def get_response_body(attributes)
      if end_point_available?
        request = request(attributes)
        client.call(Setting["remote_census.request.method_name"].to_sym, message: request).body
      else
        stubbed_response(attributes)
      end
    end

    def client
      @client = Savon.client(wsdl: Setting["remote_census.general.endpoint"])
    end

    def request(attributes)
      # structure = eval(Setting["remote_census.request.structure"])
      structure = JSON.parse(Setting["remote_census.request.structure"])
      attributes.each do |attribute|
        field = Verification::Field.find_by(name: attribute.first)
        request_path = field.assignments.from_remote_census.first.request_path
        fill_in(structure, request_path, attribute.last)
      end
      structure
    end

    def fill_in(structure, path_value, value)
      path = parse_path(path_value)

      update_value(structure, path, value) if path.present?
    end

    def parse_path(path_value)
      # path_value.split(".").map { |section| section.to_sym } if path_value.present?
      path_value.split(".") if path_value.present?
    end

    def update_value(structure, path, value)
      *path, final_key = path
      to_set = path.empty? ? structure : structure.dig(*path)

      return unless to_set
      to_set[final_key] = value
    end

    def end_point_available?
      Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
    end

    def stubbed_response(attributes)
      if (attributes[:document_number] == "12345678Z" || attributes[:document_number] == "12345678Y") && attributes[:document_type] == "1"
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
      { get_habita_datos_response: { get_habita_datos_return: { datos_habitante: {}, datos_vivienda: {}}}}
    end

end
