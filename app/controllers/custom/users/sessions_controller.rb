require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController
  include Recaptchable

  prepend_before_action :check_captcha, only: [:create]

  alias_method :consul_create, :create

  def create
    sleep rand(0.0..0.5)
    consul_create
  end
end
