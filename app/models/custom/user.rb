require_dependency Rails.root.join("app", "models", "user").to_s

class User
  devise :lockable if Rails.application.config.devise_lockable
end
