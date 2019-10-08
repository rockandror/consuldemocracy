class Admin::Wizards::Verification::HandlersController < Admin::Wizards::BaseController
  before_action :set_settings, only: :index

  def index
  end

  private

    def set_settings
      all_settings = Setting.all.group_by { |setting| setting.type }
      @settings = all_settings["custom_verification_process"]
    end

end
