require "twilio-ruby"

class SMSApi
  attr_accessor :client

  SID = Rails.application.secrets.sms_account_sid
  AUTH_TOKEN = Rails.application.secrets.sms_auth_token
  PHONE_NUMBER = Rails.application.secrets.sms_phone_number

  def initialize
    @client = Twilio::REST::Client.new SID, AUTH_TOKEN
  end

  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?

    message = @client.messages.create(
        body: "Here is your phone verification confirmation code: #{code}",
        from: PHONE_NUMBER,
        to: phone)

    success?(message)
  end

  def success?(message)
    message.error_code.blank?
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response
    {
      respuesta_sms: {
        identificador_mensaje: "1234567",
        fecha_respuesta: "Thu, 20 Aug 2015 16:28:05 +0200",
        respuesta_pasarela: {
          codigo_pasarela: "0000",
          descripcion_pasarela: "Operación ejecutada correctamente."
        },
        respuesta_servicio_externo: {
          codigo_respuesta: "1000",
          texto_respuesta: "Success"
        }
      }
    }
  end
end
