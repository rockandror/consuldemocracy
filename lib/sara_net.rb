require 'savon'
require 'openssl'

class SaraNet
  def initialize
    if ENV['SOAP_VERIFICAR_IDENTIDAD_NIF_FUNCIONARIO'].nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_NIF_FUNCIONARIO not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_IDENTIDAD_IDENTIFICADOR_SOLICITANTE'].nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_IDENTIFICADOR_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_IDENTIDAD_NOMBRE_SOLICITANTE'].nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_NOMBRE_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_IDENTIDAD_COD_PROCEDIMIENTO'].nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_COD_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_IDENTIDAD_NOMBRE_PROCEDIMIENTO'].nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_NOMBRE_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_IDENTIDAD_ID_EXPEDIENTE'].nil?
      ENV['SOAP_VERIFICAR_IDENTIDAD_ID_EXPEDIENTE'] = ""
    end

    if ENV['SOAP_VERIFICAR_IDENTIDAD_FINALIDAD'].nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_FINALIDAD not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_RESIDENCIA_NIF_FUNCIONARIO'].nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_NIF_FUNCIONARIO not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_RESIDENCIA_IDENTIFICADOR_SOLICITANTE'].nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_IDENTIFICADOR_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_RESIDENCIA_NOMBRE_SOLICITANTE'].nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_NOMBRE_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_RESIDENCIA_COD_PROCEDIMIENTO'].nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_COD_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_RESIDENCIA_NOMBRE_PROCEDIMIENTO'].nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_NOMBRE_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_VERIFICAR_RESIDENCIA_ID_EXPEDIENTE'].nil?
      ENV['SOAP_VERIFICAR_RESIDENCIA_ID_EXPEDIENTE'] = ""
    end

    if ENV['SOAP_VERIFICAR_RESIDENCIA_FINALIDAD'].nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_FINALIDAD not found as environment variable. Needed for Sara Network"
    end

    if ENV['SOAP_PLATINO_PKCS12_PASSWORD'].nil?
      raise "SOAP_PLATINO_PKCS12_PASSWORD not found as environment variable. Needed for Sara Network"
    end

    if not Rails.env.test? and not File.exist?(Rails.root + "ssl/platino.p12")
      raise "Certificate for Platino not found. Needed for Sara Network"
    end

    nspaces = {
      "xmlns:svd"  => ENV["SOAP_URL_SVD"],
      "xmlns:pet"  => ENV["SOAP_URL_PET"],
      "xmlns:ver"  => ENV["SOAP_URL_VER"],
      "xmlns:ver1" => ENV["SOAP_URL_VER1"],
      "xmlns:amb"  => ENV["SOAP_URL_AMB"],
      "xmlns:ns8"  => ENV["SOAP_URL_NS8"]
    }

    if not Rails.env.test?
      pkcs = OpenSSL::PKCS12.new(File.read(Rails.root + "ssl/platino.p12"), ENV['SOAP_PLATINO_PKCS12_PASSWORD'])

      @client = Savon.client do
        wsdl ENV["SARA_WSDL_URL"]
        wsse_auth(ENV["SOAP_PLATINO_USUARIO"], ENV["SOAP_PLATINO_PKCS12_PASSWORD"])
        wsse_signature Akami::WSSE::Signature.new(
            Akami::WSSE::Certs.new(
                cert_string:            pkcs.certificate.to_pem.to_s,
                private_key_string:     pkcs.key.to_pem.to_s,
            )
        )
        ssl_verify_mode :none
        namespace_identifier :svd
        pretty_print_xml true
        follow_redirects true
        log true
        log_level :debug
        env_namespace :soapenv
        convert_request_keys_to :none
        namespaces nspaces
      end
    end
  end

  def operations
    @client.operations
  end

  def get_request(client, message)
    # list of operations can be found using client.operations
    ops = client.operation(:peticion_sincrona)

    # build the body of the xml inside the message here
    ops.build(message: message).to_s
  end

  def verify_residence(request_id, document_type, document_number, gender, date_of_birth, postal_code)
    if document_number.nil?
      raise "Document NIF is needed in order to check identity."
    end

    # Verificar identidad
    message = build_message_verify_indentity(document_number, document_type, date_of_birth)
    response = @client.call(:peticion_sincrona, message: message)
    if response.xml.match(/CodigoEstado>\s*00\s*<\//) == nil then
      return false
    end

    # Verificar residencia
    message = build_message_VERIFICAR_RESIDENCIA(document_number, document_type, postal_code)
    response = @client.call(:peticion_sincrona, message: message) #, :soap_header => signer.signature_node)
    if response.xml.match(/CodigoEstado>\s*0003\s*<\//) == nil then
      return false
    end
    return response.body[:peticion_sincrona_response][:respuesta][:transmisiones][:transmision_datos][:datos_especificos_residencia_fecha_ultima_variacion][:retorno][:domicilio][:direccion][:cod_postal] == postal_code
  end

  private

  def build_message_verify_indentity(document_number, document_type, date_of_birth)
    {
      "pet:PeticionSincrona": {
        "pet:NifFuncionario": ENV['SOAP_VERIFICAR_IDENTIDAD_NIF_FUNCIONARIO'],
        "pet:Atributos": {
          "pet:CodigoCertificado": "SVDDGPVIWS02"
        },
        "pet:Solicitudes": {
          "pet:SolicitudTransmision": {
            "pet:DatosGenericos": {
              "pet:Solicitante": {
                "pet:IdentificadorSolicitante": ENV['SOAP_VERIFICAR_IDENTIDAD_IDENTIFICADOR_SOLICITANTE'],
                "pet:NombreSolicitante": ENV['SOAP_VERIFICAR_IDENTIDAD_NOMBRE_SOLICITANTE'],
                "pet:Procedimiento": {
                  "pet:CodProcedimiento": ENV['SOAP_VERIFICAR_IDENTIDAD_COD_PROCEDIMIENTO'],
                  "pet:NombreProcedimiento": ENV['SOAP_VERIFICAR_IDENTIDAD_NOMBRE_PROCEDIMIENTO'],
                },
                "pet:Finalidad": ENV['SOAP_VERIFICAR_IDENTIDAD_FINALIDAD'],
                "pet:Consentimiento": "Si"
              },
              "pet:Titular": {
                "pet:TipoDocumentacion": get_document_type(document_type),
                "pet:Documentacion": document_number
              }
            },
            "pet:DatosEspecificosVerificacionIdentidad": {
              "ver:Consulta": {
                #"ver:Sexo": "F",
                "ver:DatosNacimiento": {
                  "ver:Fecha": date_of_birth.strftime("%Y%m%d")
                }
              }
            }
          }
        }
      }
    }
  end

  def build_message_VERIFICAR_RESIDENCIA(document_number, document_type, postal_code)
    {
      "pet:PeticionSincrona": {
        "pet:NifFuncionario": ENV['SOAP_VERIFICAR_RESIDENCIA_NIF_FUNCIONARIO'],
        "pet:Atributos": {
          "pet:CodigoCertificado": "SVDREXTFECHAWS01"
        },
        "pet:Solicitudes": {
          "pet:SolicitudTransmision": {
            "pet:DatosGenericos": {
              "pet:Solicitante": {
                "pet:IdentificadorSolicitante":  ENV['SOAP_VERIFICAR_RESIDENCIA_IDENTIFICADOR_SOLICITANTE'],
                "pet:NombreSolicitante": ENV['SOAP_VERIFICAR_RESIDENCIA_NOMBRE_SOLICITANTE'],
                "pet:Procedimiento": {
                  "pet:CodProcedimiento": ENV['SOAP_VERIFICAR_RESIDENCIA_COD_PROCEDIMIENTO'],
                  "pet:NombreProcedimiento": ENV['SOAP_VERIFICAR_RESIDENCIA_NOMBRE_PROCEDIMIENTO']
                },
                "pet:Finalidad": ENV['SOAP_VERIFICAR_RESIDENCIA_FINALIDAD'],
                "pet:Consentimiento": "Si",
                "pet:IdExpediente": ENV['SOAP_VERIFICAR_RESIDENCIA_ID_EXPEDIENTE']
              },
              "pet:Titular": {
                "pet:TipoDocumentacion": get_document_type(document_type),
                "pet:Documentacion": document_number
              }
            },
            "pet:DatosEspecificosResidenciaFechaUltimaVariacion": {
              "ns8:Solicitud": {
                "ns8:Espanol": "s",
                "ns8:Residencia": {
                  "ns8:Provincia": postal_code[0..1]
                }
              }
            }
          }
        }
      }
    }
  end

  def get_document_type(document_type)
    if document_type === "Tarjeta de residencia"
      return "NIE"
    elsif document_type === "Pasaporte"
      return "pasaporte"
    else
      return document_type
    end
  end
end
