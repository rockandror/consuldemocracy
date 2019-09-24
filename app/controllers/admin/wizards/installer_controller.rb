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
      when "participation_process"
        @settings = [[Setting.find_by(key: "process.debates"), Setting.find_by(key: "process.proposals"), Setting.find_by(key: "votes_for_proposal_success"), Setting.find_by(key: "process.polls"), Setting.find_by(key: "process.budgets")]]
      when "map"
        @settings = [[Setting.find_by(key: "feature.map"), Setting.find_by(key: "map.latitude"), Setting.find_by(key: "map.longitude"), Setting.find_by(key: "map.zoom")]]
      end
    end

end
