# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
                                        key: ENV["COOKIES_NAME"] || "_consul_session",
                                        path: ENV["RAILS_RELATIVE_URL_ROOT"] || "/"
