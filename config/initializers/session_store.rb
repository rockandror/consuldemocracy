# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
                                        key: ENV["COOKIES_NAME"] || "_consul_session",
                                        secure: Rails.env.production?,
                                        path: ENV["CONSUL_RELATIVE_URL"] || "/"
