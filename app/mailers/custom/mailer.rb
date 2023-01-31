require_dependency Rails.root.join("app", "mailers", "mailer").to_s

class Mailer < ApplicationMailer
  def send_verification_email(user)
    # Set variables you want to use in the view
    @user = user

    mail(to: user, subject: t("mailers.verified.account"))
  end
end
