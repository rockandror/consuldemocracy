class ContactController < ApplicationController
  skip_authorization_check

  invisible_captcha only: [:create], honeypot: :address, scope: :contact_form

  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(contact_params)
    if @contact_form.valid?
      Mailer.contact(contact_params[:subject], build_intro, contact_params[:message]).deliver_later
      redirect_to root_path, notice: t("contact.success")
    else
      render :new
    end
  end

  private

    def contact_params
      params.require(:contact_form).permit(allowed_params)
    end

    def allowed_params
      [:name, :email, :subject, :message, :terms_of_service]
    end

    def build_intro
      t("mailers.contact.intro", name: contact_params[:name], email: contact_params[:email],
        message: contact_params[:message])
    end
end
