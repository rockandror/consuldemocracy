OmniAuth.configure do |config|
  # Always redirect to the failure endpoint if there is an error. Normally the
  # exception would just be raised in development mode. This is useful for
  # testing your Realme error handling in development.
  config.failure_raise_out_environments = ["development", "staging"]

  # We want to see OmniAuth messages in the log
  config.logger = Rails.logger
end
