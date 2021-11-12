require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController
  def self.invisible_captcha_actions
    _process_action_callbacks.select do |callback|
      callback.raw_filter.inspect.include?("invisible_captcha")
    end.map(&:filter)
  end

  skip_before_action(*invisible_captcha_actions)
  prepend_before_action :check_captcha, only: [:create]

  private

    def check_captcha
      return if verify_recaptcha

      self.resource = resource_class.new sign_up_params
      resource.validate

      flash.delete(:recaptcha_error)
      flash.now[:alert] = t("recaptcha.errors.verification_failed")
      render :new
    end
end
