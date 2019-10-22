class ApplicationMailer < ActionMailer::Base
  helper :settings
  helper :application
  default from: Proc.new { "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>" }
  layout "mailer"
  before_action :set_smtp_settings

  def set_smtp_settings
    SmtpConfiguration.set_configuration
  end
end
