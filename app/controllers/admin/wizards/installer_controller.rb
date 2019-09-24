class Admin::Wizards::InstallerController < Admin::BaseController
  layout "wizard"

  before_action :set_total_steps

  def new
  end

  private

    def set_total_steps
      @total_steps = 7
    end

end
