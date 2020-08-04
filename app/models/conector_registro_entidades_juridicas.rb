require "savon"

class ConectorRegistroEntidadesJuridicas

  def self.validUserAsoc?(user, urlWS)
    begin
      client_asoc = self.init(:ser, urlWS)
      message = self.build_message_asociacionesWS(user)
      response = client_asoc.call(:get_presidente_activo, message: message, soap_action: false)
      return response.body[:get_presidente_activo_response][:get_presidente_activo][:presidente]
    rescue Exception => e
      puts e.to_s
      puts e.backtrace
      return false
    end
  end

  def self.validUserFund?(user, urlWS)
    begin
      client_fund = self.init(:fun, urlWS)

      message = self.build_message_fundacionesWS(user)
      response = client_fund.call(:get_presidente_activo, message: message, soap_action: false)
      return response.xml.match(/<isPresidentePatronato>\s*true\s*<\/isPresidentePatronato>/) != nil
    rescue Exception => e
      puts e.to_s
      puts e.backtrace
      return false
    end
  end

  private

  def self.init(namespace, v)
    return Savon.client(
        #ssl_cert_file: (Rails.root + "ssl/ecociv-consul.pem").to_s,
        #ssl_cert_key_file: (Rails.root + "ssl/ecociv-consul-pk.pem").to_s,
        ssl_verify_mode: :none,
        follow_redirects: true,
        pretty_print_xml: true,
        wsdl: v,
        namespace_identifier: namespace,
        env_namespace: :soapenv,
        soap_header: {}
    )
  end

  def self.build_message_asociacionesWS(user)
    {
      uidUsuario: ENV["USUARIO_WS_ASOCIACIONES"],
      docPresidente: user[:document_number]
    }
  end

  def self.build_message_fundacionesWS(user)
    {
      uidUsuario: ENV["USUARIO_WS_FUNDACIONES"],
      docPresidente: user[:document_number]
    }
  end
end
