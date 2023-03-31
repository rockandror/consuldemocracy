require_dependency Rails.root.join("app", "controllers", "admin", "settings_controller")

class Admin::SettingsController < Admin::BaseController
  alias_method :consul_index, :index

  def index
    consul_index
    all_settings = Setting.all.group_by(&:type)
    @security_options_settings = all_settings["security_options"]
  end
end
