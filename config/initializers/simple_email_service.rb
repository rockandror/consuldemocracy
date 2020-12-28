if Rails.env.production? || Rails.env.staging? || Rails.env.preproduction?
  ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
    access_key_id: Rails.application.secrets.amazon_ses_access_key,
    secret_access_key: Rails.application.secrets.amazon_ses_secret_key,
    server: "email.#{Rails.application.secrets.amazon_ses_region}.amazonaws.com",
    region: Rails.application.secrets.amazon_ses_region
end
