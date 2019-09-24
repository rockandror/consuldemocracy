class Admin::Wizards::InstallerController < Admin::BaseController
  layout "wizard"

  before_action :set_total_steps
  before_action :set_settings, only: :show

  def new
  end

  def show
    render params[:id]
  end

  private

    def set_total_steps
      @total_steps = 7
    end

    def set_settings
      case params[:id]
      when "general_settings"
        @settings = [Setting.find_by(key: "org_name"), Setting.find_by(key: "min_age_to_participate")]
      end
    end

end
