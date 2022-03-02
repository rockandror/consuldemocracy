module OpenAmHelper
  require 'rest-client'

  def get_open_am_token

    url = build_url("/json/authenticate")

    response = RestClient.post(url,
                               {},
                               headers = {
                                 "Content-Type" => "application/json",
                                 "X-OpenAM-Username" => Rails.application.secrets.openam_username,
                                 "X-OpenAM-Password" => Rails.application.secrets.openam_password
                               })

    if response.code == 200
      ActiveSupport::JSON.decode(response.body)["tokenId"]
    else
      nil
    end
  end

  def register_user(user)
    body = {
      "input": {
        "user": {
          "username": user.username,
          "givenName": user.name,
          "mail": user.email,
          "userPassword": user.password,
          "inetUserStatus": "Active",
          "sn":"None"

        }
      }
    }.to_json

    url = build_url("/json/selfservice/userRegistration?_action=submitRequirements")

    begin
      logger.debug(url)
      response = RestClient.post(url, body, {"Content-Type": "application/json"})

    rescue Exception => e
      ebody = {
          "input": {
              "user": {
                  "username": user.username,
                  "givenName": user.name,
                  "mail": user.email,
                  "userPassword": "********",
                  "inetUserStatus": "Active",
                  "sn":"None"

              }
          }
      }.to_json
      logger.info("AUDIT") { "#{user} failed to create OpenAM, excepcion raised.\nURL: #{url}\nBODY: #{ebody}" }
      logger.error(e)
      return :error
    end

    case response.code
    when 200
      logger.info("AUDIT") { "#{user} created in OpenAM" }
      return :ok
    when 409
      logger.info("AUDIT") { "#{user}duplicated OpenAM" }
      return :duplicated
    else
      ebody = {
          "input": {
              "user": {
                  "username": user.username,
                  "givenName": user.name,
                  "mail": user.email,
                  "userPassword": "********",
                  "inetUserStatus": "Active",
                  "sn":"None"

              }
          }
      }.to_json
      logger.info("AUDIT") { "#{user} failed to create OpenAM.\nURL: #{url}\nBODY: #{ebody}" }
      return :error
    end
  end

  private

  def build_url(endpoint)
    (Rails.application.secrets.openam_host || "localhost:8081/openam") + endpoint
  end
end
