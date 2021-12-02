module Recaptchable
  extend ActiveSupport::Concern

  private

    def check_captcha
      return if verify_recaptcha

      params.permit!
      params[:user].delete(:redeemable_code) if params[:user].present? &&
                                                params[:user][:redeemable_code].blank?

      self.resource = resource_class.new params[:user]
      resource.validate
      resource.errors.messages.delete(:organization) if resource.organization?

      flash.delete(:recaptcha_error)
      flash.now[:alert] = t("recaptcha.errors.verification_failed")
      render :new
    end
end
