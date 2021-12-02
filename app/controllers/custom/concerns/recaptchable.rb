module Recaptchable
  extend ActiveSupport::Concern

  private

    def check_captcha
      return if verify_recaptcha

      self.resource = resource_class.new(permitted_params)
      resource.validate
      resource.errors.messages.delete(:organization) if resource.organization?

      flash.delete(:recaptcha_error)
      flash.now[:alert] = t("recaptcha.errors.verification_failed")
      render :new
    end

    def permitted_params
      if respond_to?(:sign_up_params, true)
        sign_up_params
      else
        sign_in_params
      end
    end
end
