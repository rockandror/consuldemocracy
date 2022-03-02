require 'savon'
require 'openssl'

class SaraNet
  def initialize
    if Rails.application.secrets.soap_verificar_identidad_nif_funcionario.nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_NIF_FUNCIONARIO not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_identidad_identificador_solicitante.nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_IDENTIFICADOR_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_identidad_nombre_solicitante.nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_NOMBRE_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_identidad_cod_procedimiento.nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_COD_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_identidad_nombre_procedimiento.nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_NOMBRE_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_identidad_id_expediente.nil?
      Rails.application.secrets.soap_verificar_identidad_id_expediente = ""
    end

    if Rails.application.secrets.soap_verificar_identidad_finalidad.nil?
      raise "SOAP_VERIFICAR_IDENTIDAD_FINALIDAD not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_residencia_nif_funcionario.nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_NIF_FUNCIONARIO not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_residencia_identificador_solicitante.nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_IDENTIFICADOR_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_residencia_nombre_solicitante.nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_NOMBRE_SOLICITANTE not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_residencia_cod_procedimiento.nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_COD_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_residencia_nombre_procedimiento.nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_NOMBRE_PROCEDIMIENTO not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_verificar_residencia_id_expediente.nil?
      Rails.application.secrets.soap_verificar_residencia_id_expediente = ""
    end

    if Rails.application.secrets.soap_verificar_residencia_finalidad.nil?
      raise "SOAP_VERIFICAR_RESIDENCIA_FINALIDAD not found as environment variable. Needed for Sara Network"
    end

    if Rails.application.secrets.soap_platino_pkcs12_password.nil?
      raise "SOAP_PLATINO_PKCS12_PASSWORD not found as environment variable. Needed for Sara Network"
    end

    if not Rails.env.test? and not File.exist?(Rails.root + "ssl/platino.p12")
      raise "Certificate for Platino not found. Needed for Sara Network"
    end

    nspaces = {
      "xmlns:svd"  => Rails.application.secrets.soap_url_svd,
      "xmlns:pet"  => Rails.application.secrets.soap_url_pet,
      "xmlns:ver"  => Rails.application.secrets.soap_url_ver,
      "xmlns:ver1" => Rails.application.secrets.soap_url_ver1,
      "xmlns:amb"  => Rails.application.secrets.soap_url_amb,
      "xmlns:ns8"  => Rails.application.secrets.soap_url_ns8
    }

    if not Rails.env.test?
      pkcs = OpenSSL::PKCS12.new(File.read(Rails.root + "ssl/platino.p12"), Rails.application.secrets.soap_platino_pkcs12_password)

      @client = Savon.client do
        wsdl Rails.application.secrets.sara_wsdl_url
        wsse_auth(Rails.application.secrets.soap_platino_usuario, Rails.application.secrets.soap_platino_pkcs12_password)
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
        "pet:NifFuncionario": Rails.application.secrets.soap_verificar_identidad_nif_funcionario,
        "pet:Atributos": {
          "pet:CodigoCertificado": "SVDDGPVIWS02"
        },
        "pet:Solicitudes": {
          "pet:SolicitudTransmision": {
            "pet:DatosGenericos": {
              "pet:Solicitante": {
                "pet:IdentificadorSolicitante": Rails.application.secrets.soap_verificar_identidad_identificador_solicitante,
                "pet:NombreSolicitante": Rails.application.secrets.soap_verificar_identidad_nombre_solicitante,
                "pet:Procedimiento": {
                  "pet:CodProcedimiento": Rails.application.secrets.soap_verificar_identidad_cod_procedimiento,
                  "pet:NombreProcedimiento": Rails.application.secrets.soap_verificar_identidad_nombre_procedimiento,
                },
                "pet:Finalidad": Rails.application.secrets.soap_verificar_identidad_finalidad,
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
        "pet:NifFuncionario": Rails.application.secrets.soap_verificar_residencia_nif_funcionario,
        "pet:Atributos": {
          "pet:CodigoCertificado": "SVDREXTFECHAWS01"
        },
        "pet:Solicitudes": {
          "pet:SolicitudTransmision": {
            "pet:DatosGenericos": {
              "pet:Solicitante": {
                "pet:IdentificadorSolicitante":  Rails.application.secrets.soap_verificar_residencia_identificador_solicitante,
                "pet:NombreSolicitante": Rails.application.secrets.soap_verificar_residencia_nombre_solicitante,
                "pet:Procedimiento": {
                  "pet:CodProcedimiento": Rails.application.secrets.soap_verificar_residencia_cod_procedimiento,
                  "pet:NombreProcedimiento": Rails.application.secrets.soap_verificar_residencia_nombre_procedimiento
                },
                "pet:Finalidad": Rails.application.secrets.soap_verificar_residencia_finalidad,
                "pet:Consentimiento": "Si",
                "pet:IdExpediente": Rails.application.secrets.soap_verificar_residencia_id_expediente
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
