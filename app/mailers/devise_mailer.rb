class DeviseMailer < Devise::Mailer
  helper :application, :settings
  include Devise::Controllers::UrlHelpers
  default template_path: "devise/mailer"
  before_action :set_smtp_settings

  def set_smtp_settings
    SmtpConfiguration.set_configuration
  end

  protected

  def devise_mail(record, action, opts = {})
    I18n.with_locale record.locale do
      super(record, action, opts)
    end
  end
end
