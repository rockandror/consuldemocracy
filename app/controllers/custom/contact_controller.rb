class ContactController < ApplicationController
  skip_authorization_check

  invisible_captcha only: [:create], honeypot: :address

  def new
    render action: :contact
  end

  def create
    Mailer.contact(contact_params[:username], contact_params[:email], contact_params[:subject], contact_params[:email_body]).deliver_later
    redirect_to root_path, notice: t("contact.success")
  end

  private
  def contact_params
    params.permit(:username, :email, :subject, :email_body)
  end
end
