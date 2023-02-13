require_dependency Rails.root.join("app", "controllers", "admin", "system_emails_controller").to_s

class Admin::SystemEmailsController
  alias_method :consul_index, :index
  alias_method :consul_view, :view

  def index
    consul_index
    @system_emails[:contact] = %w[view edit_info]
  end

  def view
    if @system_email == "contact"
      load_sample_contact
    else
      consul_view
    end
  end

  private

    def load_sample_contact
      @subject = "Asunto de ejemplo"
      @intro = I18n.t("mailers.contact.intro", name: "Juan", email: "juan@mail.com")
      @message = "Mensaje de ejemplo"
    end
end
