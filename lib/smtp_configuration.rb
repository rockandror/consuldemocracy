class SmtpConfiguration
  def self.set_configuration
    if (Rails.env.production? || Rails.env.staging? || Rails.env.preproduction?) && Setting["feature.smtp_configuration"].present?
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        address:              Setting["smtp.address"],
        port:                 Setting["smtp.port"],
        domain:               Setting["smtp.domain"],
        authentication:       Setting["smtp.authentication"],
        user_name:            Setting["smtp.username"],
        password:             Setting["smtp.password"],
        enable_starttls_auto: Setting["smtp.enable_starttls_auto"].present?
      }
    end
  end

end
