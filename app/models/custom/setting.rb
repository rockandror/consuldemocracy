require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    def defaults
      consul_defaults.merge({
        "mailer_from_address": "noreply@desarrollowebagil.com",
        "mailer_from_name": "Consul on AWS EBS"
      })
    end
  end
end
