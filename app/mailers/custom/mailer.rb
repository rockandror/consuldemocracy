require_dependency Rails.root.join("app", "mailers", "mailer").to_s

class Mailer
  def contact(subject, intro, message)
    @message = message
    @subject = subject
    @intro = intro
    @email_to = Rails.application.secrets.contact_email

    I18n.with_locale(I18n.default_locale) do
      mail(to: @email_to, subject: @subject)
    end
  end
end
