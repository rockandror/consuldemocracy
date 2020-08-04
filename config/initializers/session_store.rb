# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: ENV["COOKIES_NAME"].nil? ? "_consul_session" : ENV["COOKIES_NAME"].to_s, secure: Rails.env.production?, path: ENV["CONSUL_RELATIVE_URL"].nil? ? "/" : ENV["CONSUL_RELATIVE_URL"].to_s
