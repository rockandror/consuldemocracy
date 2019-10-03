class Admin::Wizards::VerificationController < Admin::BaseController
  layout "wizard"

  before_action :set_total_steps
  before_action :set_settings, only: :show

  def new
    all_settings = Setting.all.group_by { |setting| setting.type }
    @settings = [Setting.find_by(key: "feature.custom_verification_process"), Setting.find_by(key: "feature.user.skip_verification")]
  end

  def show
  end

  private

    def set_total_steps
      @total_steps = 7
    end

    def next_step

    end

    def set_settings
      case params[:id]
      when "general_settings"
        @settings = [Setting.find_by(key: "org_name"),
                     Setting.find_by(key: "min_age_to_participate")]
      when "participation_process"
        @settings = [[Setting.find_by(key: "process.debates"),
                      Setting.find_by(key: "process.proposals"),
                      Setting.find_by(key: "votes_for_proposal_success"),
                      Setting.find_by(key: "process.polls"),
                      Setting.find_by(key: "process.budgets")]]
      when "map"
        @settings = [[Setting.find_by(key: "feature.map"),
                      Setting.find_by(key: "map.latitude"),
                      Setting.find_by(key: "map.longitude"),
                      Setting.find_by(key: "map.zoom")]]
      when "smtp"
        @settings = [Setting.find_by(key: "feature.smtp_configuration"),
                     Setting.find_by(key: "smtp.address"),
                     Setting.find_by(key: "smtp.port"),
                     Setting.find_by(key: "smtp.domain"),
                     Setting.find_by(key: "smtp.username"),
                     Setting.find_by(key: "smtp.password"),
                     Setting.find_by(key: "smtp.authentication"),
                     Setting.find_by(key: "smtp.enable_starttls_auto")]
      when "regional"
        all_settings = Setting.all.group_by { |setting| setting.type }
        @settings = [all_settings["regional.default_locale"]] + [all_settings["regional.available_locale"]] + [all_settings["regional.time_zone"]]
      end
    end

end
