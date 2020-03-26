Yt.configure do |config|
    config.api_key = Rails.application.secrets.yt_api_key
    config.client_id = Rails.application.secrets.yt_client_id
    config.client_secret = Rails.application.secrets.yt_client_secret
    config.log_level = :debug

end
