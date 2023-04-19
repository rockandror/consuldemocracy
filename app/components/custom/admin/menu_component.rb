require_dependency Rails.root.join("app", "components", "admin", "menu_component")

class Admin::MenuComponent
  alias_method :original_links, :links

  def links
    custom_links = []
    custom_links = [audits_link] if Rails.application.config.auditing_enabled

    original_links + custom_links
  end

  private

    def audits_link
      [
        t("admin.menu.audits"),
        admin_audits_path,
        controller_name == "audits",
        class: "audits-link"
      ]
    end
end
